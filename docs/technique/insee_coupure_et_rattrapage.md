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
