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
la durée de `insee_calls_pause_duration` (1 h par défaut).

Il est armé par le **client**, dans les trois situations où l’INSEE nous refuse :

| Origine | Erreur | Sens |
| -- | -- | -- |
| `POST .../token` | 400 | identifiants refusés — l’erreur observée en production |
| `POST .../token` | 401 | identifiants refusés |
| `GET .../siret/…` | 401, **deux fois de suite** | jeton refusé, même renouvelé |

Un 401 de Sirene ne coupe pas du premier coup. Comme le recommande l’INSEE, on renouvelle alors le
jeton et on rejoue l’appel **une fois** : un jeton expiré ou révoqué avant la durée annoncée se règle
ainsi sans coupure. On ne coupe que si le jeton neuf est refusé à son tour. Si ce sont les identifiants
qui sont faux, c’est la demande de jeton qui échoue (400) et coupe, pour un seul échec
d’authentification. Le 30/09, un 401 isolé avait coupé les appels six heures.

Toutes remontent en `AbstractINSEEAPIClient::UnavailableError`, que le job `discard_on` : réessayer ne
peut pas aboutir et ne ferait qu’alimenter le compteur de verrouillage.

### Pourquoi 1 h

L’INSEE verrouille le compte **30 minutes après 5 échecs d’authentification sur 12 heures**, compteur
commun au jeton, au renouvellement et au portail. Chaque fin de coupure relance un appel : si les
identifiants sont vraiment faux, une coupure d’1 h produit une douzaine d’échecs par nuit, donc un
compte verrouillé jusqu’au matin. Ce n’est acceptable que parce que le compte **n’est pas partagé**
avec d’autres applications et que chaque coupure remonte dans Sentry en `error` : on corrige le
matin (voir « Après une coupure »). Une coupure plus longue (6 h) ne verrouillerait jamais, mais
immobiliserait le rattrapage six heures au moindre incident passager.

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
(`ConnectionFailed`, `TimeoutError`) sont rejouées par le client. Les 5xx, les 429, les pannes réseau
persistantes et les réponses illisibles sont rejoués par ActiveJob, avec un backoff polynomial (3 s,
18 s, 83 s, 4 min), **cinq tentatives au plus, toutes erreurs confondues** :
c’est la stratégie que recommande la documentation de l’API Sirene privée, qui ne considère le service
en panne qu’après quatre ou cinq échecs espacés. Au-delà, le job abandonne, compte l’échec sur
l’organisation et le remonte dans Sentry en `error` ; il n’a pas écrit `last_insee_payload_updated_at`,
donc le rattrapage reprendra l’organisation. Relancer à l’infini n’apporte plus rien depuis que ce
rattrapage existe.

Le jeton est mis en cache pour la durée annoncée par l’INSEE moins une minute de marge (5 minutes si
l’INSEE n’annonce rien). Le cache est par process, sans verrou : sous le GVL une affectation d’ivar est
atomique, et le jeton et son expiration voyagent dans le même objet pour rester cohérents. Au pire,
quelques threads renouvellent en même temps à l’instant de l’expiration — tous les jetons obtenus sont
valides.

### Le jeton n’est plus empoisonnable

`conn.response :json` ne parse que sur le bon `Content-Type`. Une page HTML renvoyée en 200 par un WAF
faisait que `payload['access_token']` valait la **sous-chaîne** `"access_token"`, mise en cache cinq
minutes. Chaque appel Sirene partait ensuite en 401, donc en coupure, déclenchée par une réponse
mal typée. La réponse du jeton doit maintenant être un objet JSON portant un `access_token`, sinon rien
n’est mis en cache et l’erreur remonte en `InvalidResponseError`.

### Le compteur d’échecs

`organizations.insee_consecutive_failures` compte les jobs **consécutifs** qui ont échoué pour
l’organisation, et revient à 0 au premier succès. Avec `last_insee_payload_updated_at` (date du dernier
succès), il dit depuis quand et combien de fois l’organisation résiste.

| Issue du job | Compteur |
| -- | -- |
| Payload obtenu | remis à 0 |
| 404 (`EntityNotFoundError`) | +1 |
| 5xx, 429, réseau ou réponse illisible, après les 5 tentatives | +1 — un job, pas une tentative |
| Appels coupés (interrupteur, coupe-circuit, 401) | inchangé : aucun appel n’a atteint l’INSEE pour elle |
| Organisation exclue, étrangère ou rafraîchie depuis moins de 24 h | inchangé : pas d’appel |

Le chemin synchrone (`.new.perform` à la création) ne passe pas par les handlers d’ActiveJob et ne
compte pas ; un échec y enfile de toute façon un job, qui comptera.

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

La queue borne la **concurrence**, pas le **débit** : un worker unique enchaîne autant d’appels que
l’INSEE répond vite. Le débit est donc plafonné à part, par le `perform_throttle` de GoodJob :
`insee_calls_per_minute` exécutions par minute (250 par défaut, réglable en base). Les conditions
générales de l’API Sirene fixent 30 interrogations par minute, un quota plus élevé n’étant accordé
que sur demande approuvée par l’Insee : c’est le cas de notre compte, dont l’en-tête
`x-rate-limit-limit` annonce **500** (relevé le 30/09/2026). On n’en utilise que la moitié. Le throttle
compte sur une fenêtre glissante d’une minute : il ne dépasse le plafond sur aucune minute, quelle que
soit la façon dont l’Insee découpe les siennes.

Chaque réponse porte le quota restant : `x-rate-limit-limit`, `x-rate-limit-remaining` et
`x-rate-limit-reset` (epoch en millisecondes). Pour vérifier le quota en console :

```ruby
response = INSEESireneAPIClient.new.send(:http_connection).get("#{INSEESireneAPIClient::ETABLISSEMENT_URL}/21110274400011")
response.headers['x-rate-limit-limit']
```

Un worker unique ne tient 250 appels par minute que si chaque appel dure moins de 240 ms. Au-delà,
c’est la queue sérialisée, et non le throttle, qui borne le débit réel.

Le throttle compte **toutes** les exécutions, y compris celles qui s’arrêtent sans appeler l’INSEE.
On n’enfile donc que les jobs qui appelleront vraiment : `Organization#insee_refresh_due?` (ni
étrangère, ni exclue, ni rafraîchie depuis moins de 24 h) est vérifié avant chaque enfilement — à
chaque page vue (`AuthenticatedUserController`), à la connexion (`UpdateOrganizationINSEEPayload`) et à
la création par l’API (`EnqueueOrganizationINSEERefresh`). Sans ce filtre, chaque page vue par une
organisation étrangère prenait une place dans le plafond.

Ce plafond est un **garde-fou, pas un lissage**. Un job refusé ne patiente pas dans une file : il lève
`ThrottleExceededError` et GoodJob le replanifie avec un backoff polynomial, sans limite de tentatives.
Enfiler un gros stock d’un coup derrière ce plafond repousserait la fin du stock de plusieurs heures,
créerait une exécution en base par refus, et ferait patienter les organisations créées par les usagers
derrière le stock. Le lissage reste le travail du rattrapage (ci-dessous), calé sous le plafond.

La queue et le throttle ne protègent **pas le chemin synchrone**, qui exécute le job en ligne sans
passer par GoodJob. Là, le coupe-circuit client reste la seule protection.

## Le chemin synchrone

`FindOrCreateOrganization` pose `update_organization_insee_payload_now = true`, ce qui exécute
`UpdateOrganizationINSEEPayloadJob.new.perform` **en ligne**, pendant la requête HTTP de l’utilisateur.
Un 400 non rattrapé y remontait en 500.

`UpdateOrganizationINSEEPayload` distingue maintenant deux échecs :

| Situation | Sens | Réponse |
| -- | -- | -- |
| `EntityNotFoundError` | « ce SIRET n’existe pas » | on refuse — sauf s’il figure dans la liste d’exclusion, voir plus bas |
| Indisponibilité INSEE | « on ne sait pas » | on **crée** l’organisation et on enfile un rattrapage |

Refuser la création parce que l’INSEE est en panne ferait porter notre incident à l’utilisateur, pour
une information qu’on obtiendra de toute façon quelques minutes plus tard.

### Ce que coûte une organisation sans payload

La lecture est défensive partout, rien ne casse, mais trois effets persistent jusqu’au rattrapage :

1. `legal_category` tombe à `:other` ;
2. la recherche par nom ne trouve pas l’organisation — le ransacker `:name` interroge le JSON en SQL ;
3. **HubEE reçoit des champs vides** (`codeCommuneEtablissement`, `codePostalEtablissement`,
   `sigleUniteLegale`). C’est le plus dur : un abonnement créé dans cet état part incomplet chez un
   partenaire.

## Le rattrapage

Aucun registre parallèle : `organizations.last_insee_payload_updated_at` porte déjà l’information. Le job
ne l’écrit qu’en cas de succès, donc un appel court-circuité, échoué ou jamais tenté laisse la colonne
inchangée. Les organisations à rattraper sont exactement celles dont elle est nulle ou vieille — c’est
auto-réparateur, et ça survit à un redémarrage, à un vidage Redis et à une purge de queue.

« Vieille » veut dire **plus de `insee_refresh_stale_after`**, 30 jours par défaut, réglable en base.
Ce n’est volontairement **pas** le délai de 24 h qui évite de rappeler l’INSEE à chaque page vue
(`Organization::INSEE_REFRESH_COOLDOWN`) : avec 24 h, toute organisation que personne n’utilise
redeviendrait à rafraîchir le lendemain, et le cron balaierait tout le parc en continu sans jamais se
vider. Les organisations actives sont rafraîchies par la navigation ; le rattrapage ne sert qu’aux
jamais-rafraîchies et aux oubliées.

`Organization.needing_insee_refresh` les sélectionne : d’abord celles dont le dernier appel n’a pas
échoué, puis les jamais-rafraîchies avant les plus anciennes. Une organisation en échec (404,
abandon après cinq tentatives) n’est jamais horodatée : triée seulement par date, elle resterait en
tête de file et chaque passage reprendrait les mêmes échecs jusqu’à bloquer le rattrapage.
`RefreshStaleOrganizationsINSEEPayloadJob` les enfile **par lots étalés dans le temps** et ne fait rien
si les appels sont coupés. Le lissage est réglable sans déploiement :
`insee_refresh_batch_size` (200), `insee_refresh_batch_interval` (1 min),
`insee_refresh_max_organizations_per_run` (11 000).

Soit 200 appels par minute, sous le plafond de 250 : le reste va aux organisations créées ou visitées
par les usagers. Une exécution de 11 000 s’étale sur 55 minutes, donc tient dans l’heure qui la
sépare de la suivante — sinon le passage suivant renfilerait des organisations encore en attente.

Le job tourne **toutes les heures en production** (`config/schedule.yml`, à la 15ᵉ minute). Pas sur
staging ni sandbox : si elles partagent le compte INSEE de production, elles consommeraient le même
quota et le même compteur de verrouillage.

Il reste sur la **queue par défaut**, pas sur `insee` : il n’émet lui-même aucun appel INSEE, il se
contenterait de bloquer l’unique worker sérialisé derrière lequel les vrais appels attendent.

Le rejeu est idempotent : `return if last_update_within_24h?` en tête du job fait qu’une organisation
déjà rafraîchie coûte une requête SQL et rien d’autre. On peut donc relancer large.

### Les organisations exclues des appels

Certaines organisations ne doivent pas être demandées à l’INSEE. Le cas qui a motivé la liste :
l’INSEE répond **404** pour un établissement non diffusible ou une structure publique dont les
informations sont protégées (Défense, Gendarmerie, parlementaires…), exactement comme pour un SIRET mal
saisi ou trop récent. On ne peut donc pas les distinguer automatiquement, et sans rien faire :

- à la création (`FindOrCreateOrganization`, chemin synchrone), le 404 fait **refuser** l’organisation
  avec « n’existe pas dans le répertoire Sirene » ;
- au rattrapage, elle n’est jamais horodatée, donc **renfilée à chaque passage**, en tête de file, avec
  un warning Sentry (`EntityNotFoundError`) à chaque fois.

`insee_skipped_identifiers` liste en base les **SIRET ou SIREN** à ne pas appeler, sans dire
pourquoi — un SIREN couvre tous les établissements de la structure. Pour ces organisations, le job
n’appelle pas l’INSEE (l’organisation est créée sans payload, sans refus) et le rattrapage les ignore.

```ruby
Setting.set(:insee_skipped_identifiers, '575 397 807 42358, 130007669')   # espaces tolérés
Setting.fetch(:insee_skipped_identifiers)   # => ["57539780742358", "130007669"]
Organization.insee_skipped.count
```

`Setting.set` **remplace** la liste : pour ajouter un identifiant, repartir de la valeur actuelle
(`Setting.set(:insee_skipped_identifiers, Setting.fetch(:insee_skipped_identifiers) + ['…'])`).

Un 404 qui n’est pas dans la liste continue d’être retenté à chaque passage du rattrapage : c’est le
signal qui permet de l’y ajouter, après vérification (annuaire des entreprises, organisation). Le
compteur d’échecs les fait ressortir.

### Mesurer en console

Chaque état a son scope, limité aux organisations immatriculées à l’INSEE (les étrangères n’ont
jamais de payload) :

```ruby
Organization.without_insee_payload.count      # payload nul ou vide
Organization.never_insee_refreshed.count      # jamais rafraîchies
Organization.with_stale_insee_payload.count   # rafraîchies il y a plus de 30 jours (insee_refresh_stale_after)
Organization.with_fresh_insee_payload.count   # rafraîchies depuis moins de 30 jours
Organization.insee_skipped.count              # exclues des appels, voir ci-dessus
Organization.with_insee_failures.count        # dernier appel en échec
Organization.with_insee_failures.group(:insee_consecutive_failures).count   # répartition
Organization.where(insee_consecutive_failures: 3..).pluck(:legal_entity_id) # candidates à l’exclusion
Organization.needing_insee_refresh.count      # ce que le rattrapage va traiter

RefreshStaleOrganizationsINSEEPayloadJob.perform_later   # relancer sans attendre le cron
```

`without_insee_payload` regarde le contenu, `never_insee_refreshed` et les suivants la date du dernier
rafraîchissement réussi : un écart entre `without_insee_payload` et `never_insee_refreshed` est un
signal à creuser.

## Après une coupure

1. Vérifier que les appels sont bien arrêtés : `AbstractINSEEAPIClient.calls_allowed?` → `false`.
   Si le coupe-circuit n’est pas armé, couper à la main : `Setting.set(:insee_calls_enabled, 'false')`.
2. **Attendre 35 minutes** : si des coupures se sont enchaînées pendant la nuit, le compte est
   verrouillé, et le verrou tombe 30 minutes après le dernier échec. Tourner le mot de passe INSEE
   ensuite seulement.
3. Poser la nouvelle valeur : `Setting.set(:insee_password, '…')`. Aucun déploiement.
4. Relâcher : `INSEECallsPause.reset!`, puis `Setting.unset(:insee_calls_enabled)` si l’interrupteur
   manuel avait été utilisé.
5. Mesurer l’ampleur : `Organization.needing_insee_refresh.count`.
6. Laisser le cron horaire rattraper, ou accélérer avec `RefreshStaleOrganizationsINSEEPayloadJob.perform_later`.

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
