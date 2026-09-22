# INSEE — couper les appels sans déploiement

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
