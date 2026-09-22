# INSEE — couper les appels, puis rattraper

## Pourquoi

Le compte INSEE est verrouillé 30 minutes après **5 échecs d’authentification sur 12 heures**, et ce
compteur est **commun** au jeton, à l’API de renouvellement et au portail. Tant que DataPass continue
d’appeler l’INSEE avec des identifiants refusés, le compte est verrouillé en permanence par nos propres
appels — et la rotation du mot de passe ne peut pas aboutir.

Couper les appels est donc un **prérequis** à la rotation, pas une mitigation.

## L’interrupteur

```ruby
Setting.set(:insee_calls_enabled, 'false')   # couper
Setting.unset(:insee_calls_enabled)          # rouvrir
```

Les appels sont **activés par défaut**, et désactivés **uniquement si la valeur vaut exactement
`"false"`**. `"FALSE"`, `"0"`, `"off"` ou une chaîne vide laissent les appels actifs : une faute de
frappe ne coupe pas la production par accident, et ne la rouvre pas non plus par accident.

Comme tout `Setting`, la chaîne reste `BDD → ENV (INSEE_CALLS_ENABLED) → défaut`, et une écriture est
vue immédiatement par tous les process, sans redémarrage. Voir
[`parametrage_en_base.md`](parametrage_en_base.md).

## Où il agit

Le garde est dans le **client**, `AbstractINSEEAPIClient#ensure_insee_available!`, appelé en tête de
`INSEEAPIAuthentication#access_token` et de `INSEESireneAPIClient#etablissement`. C’est le seul point
qui couvre à la fois le job, les jobs déjà enfilés et le **chemin synchrone** — `FindOrCreateOrganization`
exécute `UpdateOrganizationINSEEPayloadJob.new.perform` en ligne, sans passer par aucune queue.

Quand l’interrupteur est fermé, les appels lèvent `AbstractINSEEAPIClient::UnavailableError` avant tout
accès réseau.

`AbstractINSEEAPIClient.calls_allowed?` est le même test, exposé pour que les jobs s’arrêtent tôt sans
charger d’organisation.

## Le coupe-circuit automatique

L’interrupteur demande une intervention humaine. `INSEECallsPause` coupe **tout seul**, sur un drapeau
Redis partagé par tous les serveurs web et les workers (`Kredis.flag('insee_calls_pause')`), posé pour
la durée de `insee_calls_pause_duration` (6 h par défaut).

Il est armé par le **client**, dans les trois situations où l’INSEE nous refuse :

| Origine | Erreur | Sens |
| -- | -- | -- |
| `POST .../token` | 400 | identifiants refusés — l’erreur observée en production |
| `POST .../token` | 401 | identifiants refusés |
| `GET .../siret/…` | 401 | jeton refusé |

Toutes remontent en `AbstractINSEEAPIClient::UnavailableError`, que le job `discard_on` : réessayer ne
peut pas aboutir et ne ferait qu’alimenter le compteur de verrouillage.

Chaque appel court-circuité incrémente `Kredis.counter('insee_skipped_calls')` — un **compteur**, pas une
liste d’identifiants à réconcilier.

### En console

```ruby
AbstractINSEEAPIClient.calls_allowed?   # les appels peuvent-ils partir ?
INSEECallsPause.paused?                 # le coupe-circuit est-il armé ?
INSEECallsPause.skipped_calls_count     # combien d’appels ont été sautés
INSEECallsPause.pause!                  # armer à la main
INSEECallsPause.reset!                  # relâcher
```

### Si Redis est injoignable

Le coupe-circuit est **fail-closed** : `paused?` renvoie `true` et plus aucun appel ne part. C’est le
sens sûr — l’inverse rejouerait l’incident, chaque échec repartant vers l’INSEE jusqu’au verrouillage.

Kredis 1.8 avale les `Redis::BaseError` et renvoie `nil` (`proxy/failsafe.rb`), ce qui rend un `nil`
indistinguable d’un « non armé ». `INSEECallsPause` passe donc par `failsafe(returning:)`, l’API publique
qui suspend cet avalement et fournit la valeur de repli.

`pause!` et `reset!` **relisent le drapeau** après écriture, renvoient `false` si elle n’a pas abouti et
le signalent à Sentry en `error`. Croire avoir coupé sans avoir coupé est le pire des deux mondes.

## L’amplification retirée

Le nombre d’appels était le vrai moteur de l’incident :

- `INSEEAPIAuthentication#http_connection` **empilait deux middlewares `:retry`** — celui de la classe
  abstraite et le sien. Six tentatives fois six, soit jusqu’à 36 `POST token` par jeton obtenu.
- `Faraday::ClientError` figurait dans les exceptions retentées, or `Faraday::BadRequestError` en hérite.
  Un 400 était donc rejoué alors qu’il ne peut pas aboutir.
- **Le jeton n’était pas mis en cache** : le lambda `Bearer` instanciait un client neuf et refaisait un
  `POST token` à chaque tentative de chaque requête.

Désormais un seul middleware `:retry`, configuré par `retry_options`, et seules les pannes de transport
(`ConnectionFailed`, `TimeoutError`) sont rejouées par le client. Les 5xx et les réponses illisibles sont
rejoués par ActiveJob, avec un backoff, une fois par niveau.

Le jeton est mis en cache pour la durée annoncée par l’INSEE moins une minute de marge (5 minutes si
l’INSEE n’annonce rien). Le cache est par process, sans verrou : sous le GVL une affectation d’ivar est
atomique, et le jeton et son expiration voyagent dans le même objet pour rester cohérents. Au pire,
quelques threads renouvellent en même temps à l’instant de l’expiration — tous les jetons obtenus sont
valides.

### Le jeton n’est plus empoisonnable

`conn.response :json` ne parse que sur le bon `Content-Type`. Une page HTML renvoyée en 200 par un WAF
faisait que `payload['access_token']` valait la **sous-chaîne** `"access_token"`, mise en cache cinq
minutes. Chaque appel Sirene partait ensuite en 401, donc en coupure de 6 h, déclenchée par une réponse
mal typée. La réponse du jeton doit maintenant être un objet JSON portant un `access_token`, sinon rien
n’est mis en cache et l’erreur remonte en `InvalidResponseError`.

## La queue sérialisée

`UpdateOrganizationINSEEPayloadJob` tourne sur la queue **`insee`, à concurrence 1**
(`config/initializers/good_job.rb`, `'insee:1;-insee'` : un pool d’un thread pour `insee`, un pool pour
tout le reste). Le débit devient une propriété de configuration au lieu d’une discipline d’opérateur.

**C’est elle qui rend la borne du coupe-circuit réelle.** Sans elle, les jobs déjà en vol sur les autres
threads sont passés devant `calls_allowed?` avant que le drapeau ne soit posé, et partent quand même :
avec cinq threads par process et plusieurs process, c’est dix à vingt échecs d’authentification avant que
la coupure ne soit vue — bien au-delà du seuil de verrouillage de cinq. Avec un seul worker, le premier
échec arme le drapeau et tous les suivants sortent tôt.

L’initializer **prime sur `GOOD_JOB_QUEUES`** dans GoodJob, d’où le `ENV.fetch` : une variable posée au
déploiement reste prioritaire. Et l’exclusion `-insee` est nécessaire — `*` inclurait `insee`, donc le
pool général y piocherait aussi et la sérialisation ne tiendrait pas.

Deux limites à connaître :

- avec `conn.options.timeout = 2`, un worker unique plafonne autour de 30 appels/minute, soit le quota
  INSEE Sirene. C’est heureux, mais c’est une **coïncidence** : baisser le timeout augmenterait le débit.
- la queue ne protège **pas le chemin synchrone**, qui exécute le job en ligne sans passer par aucune
  queue. Là, le coupe-circuit client reste la seule protection.

## Le chemin synchrone

`FindOrCreateOrganization` pose `update_organization_insee_payload_now = true`, ce qui exécute
`UpdateOrganizationINSEEPayloadJob.new.perform` **en ligne**, pendant la requête HTTP de l’utilisateur.
Un 400 non rattrapé y remontait en 500.

`UpdateOrganizationINSEEPayload` distingue maintenant deux échecs :

| Situation | Sens | Réponse |
| -- | -- | -- |
| `EntityNotFoundError` | « ce SIRET n’existe pas » | on refuse — l’information est certaine |
| Indisponibilité INSEE | « on ne sait pas » | on **crée** l’organisation et on enfile un rattrapage |

Refuser la création parce que l’INSEE est en panne ferait porter notre incident à l’utilisateur, pour
une information qu’on obtiendra de toute façon quelques minutes plus tard.

### Ce que coûte une organisation sans payload

La lecture est défensive partout, rien ne casse, mais trois effets persistent jusqu’au rattrapage :

1. `legal_category` tombe à `:other`, ce qui fait basculer une demande CNOUS du périmètre géographique
   automatique à la saisie manuelle (voir plus bas) ;
2. la recherche par nom ne trouve pas l’organisation — le ransacker `:name` interroge le JSON en SQL ;
3. **HubEE reçoit des champs vides** (`codeCommuneEtablissement`, `codePostalEtablissement`,
   `sigleUniteLegale`). C’est le plus dur : un abonnement créé dans cet état part incomplet chez un
   partenaire.

## Le périmètre géographique CNOUS, rejouable

`legal_category` n’a qu’un seul lecteur : `populate_codes_insee_and_entity`, dans
`AuthorizationExtensions::CnousDataExtractionCriteria`. Sans payload INSEE, la catégorie n’est pas mappée
**et** le code commune est nil : `entity_type` reste vide, donc `geographic_perimeter_automatic?` est
faux, donc la validation exige que le demandeur saisisse lui-même les codes INSEE de communes. Ce n’est
pas une donnée fausse — c’est un basculement de parcours.

Le problème était le **timing** : le hook était un `after_commit ... on: :create`, donc il ne tournait
qu’une fois. Un payload arrivant cinq minutes plus tard par le rattrapage ne le rejouait pas, et la
demande restait en saisie manuelle définitivement.

`populate_codes_insee_and_entity` est désormais public et rejouable.
`UpdateOrganizationINSEEPayloadJob` enfile `PopulateDraftRequestsGeographicPerimeterJob` dès que
`insee_payload` a réellement changé ; ce job rejoue le calcul sur les demandes de l’organisation encore
en `draft` qui portent le bloc CNOUS. Le garde `return if geographic_perimeter_automatic?` rend le rejeu
idempotent.

⚠️ Seules les demandes en `draft` sont rejouées. Corriger le périmètre d’une demande déjà soumise est une
décision métier, pas une correction technique.

### Les dégradations silencieuses sont tracées

Trois chemins menaient au même `return` muet. Deux sont instrumentés, le troisième ne l’est pas parce
qu’il est légitime :

| Cas | Trace |
| -- | -- |
| catégorie juridique non mappée (ni commune, ni département, ni région) | aucune — c’est le fonctionnement normal |
| payload INSEE absent | `Sentry.capture_message(…, level: :warning)` |
| code commune absent du payload, ou commune inconnue de l’API Géo | `Sentry.capture_message(…, level: :warning)` |
| API Géo en panne | `Sentry.capture_exception(…, level: :warning)` |

Le cas « API Géo en panne » produisait déjà cet effet **avant l’incident INSEE**, et personne ne l’avait
jamais vu.

## Le rattrapage

Aucun registre parallèle : `organizations.last_insee_payload_updated_at` porte déjà l’information. Le job
ne l’écrit qu’en cas de succès, donc un appel court-circuité, échoué ou jamais tenté laisse la colonne
inchangée. Les organisations à rattraper sont exactement celles dont elle est nulle ou vieille — c’est
auto-réparateur, et ça survit à un redémarrage, à un vidage Redis et à une purge de queue.

`Organization.needing_insee_refresh` les sélectionne, les jamais-rafraîchies d’abord.
`RefreshStaleOrganizationsINSEEPayloadJob` les enfile **par lots étalés dans le temps** et ne fait rien
si les appels sont coupés. Le lissage est réglable sans déploiement :
`insee_refresh_batch_size` (50), `insee_refresh_batch_interval` (1 min),
`insee_refresh_max_organizations_per_run` (500).

Il reste sur la **queue par défaut**, pas sur `insee` : il n’émet lui-même aucun appel INSEE, il se
contenterait de bloquer l’unique worker sérialisé derrière lequel les vrais appels attendent.

Le rejeu est idempotent : `return if last_update_within_24h?` en tête du job fait qu’une organisation
déjà rafraîchie coûte une requête SQL et rien d’autre. On peut donc relancer large.

```ruby
Organization.needing_insee_refresh.count          # mesurer avant de relancer
RefreshStaleOrganizationsINSEEPayloadJob.perform_later
```

⚠️ **Le job n’est planifié nulle part.** Le débit acceptable pour l’INSEE reste à mesurer avant de le
mettre au cron. Tant qu’il n’y est pas, une organisation créée pendant une coupure reste sans payload
jusqu’à un déclenchement manuel.

## Après une coupure

1. Vérifier que les appels sont bien arrêtés : `AbstractINSEEAPIClient.calls_allowed?` → `false`.
   Si le coupe-circuit n’est pas armé, couper à la main : `Setting.set(:insee_calls_enabled, 'false')`.
2. Tourner le mot de passe INSEE — le compte doit être déverrouillé, donc les appels arrêtés depuis plus
   de 30 minutes.
3. Poser la nouvelle valeur : `Setting.set(:insee_password, '…')`. Aucun déploiement.
4. Relâcher : `INSEECallsPause.reset!`, puis `Setting.unset(:insee_calls_enabled)` si l’interrupteur
   manuel avait été utilisé.
5. Mesurer l’ampleur : `Organization.needing_insee_refresh.count`.
6. Rattraper par vagues : `RefreshStaleOrganizationsINSEEPayloadJob.perform_later`, à répéter.

## Les identifiants

Les quatre identifiants INSEE passent par `Setting` :

```ruby
Setting.fetch(:insee_client_id)
Setting.fetch(:insee_client_secret)
Setting.fetch(:insee_username)
Setting.fetch(:insee_password)
```

La chaîne `BDD → ENV → credentials` préserve le comportement existant — une variable d’environnement ou
une valeur en credentials continue d’être lue — et ajoute la base devant. **La rotation du mot de passe
ne demande donc plus ni PR ni déploiement** :

```ruby
Setting.set(:insee_password, '…')
```
