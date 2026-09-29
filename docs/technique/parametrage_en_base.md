# Paramétrage en base

`Setting` permet de changer une valeur de configuration **sans PR et sans déploiement**, depuis
`bin/remote-console`. C’est la seule surface de configuration manipulable quand déployer est justement
ce qu’on ne peut pas faire vite — une rotation de secret pendant un incident, par exemple.

## La chaîne de lecture

```
base de données  →  variable d’environnement  →  credentials  →  défaut déclaré
```

La première source qui répond gagne. Une valeur vide en base ne masque pas la suite de la chaîne : elle
est ignorée comme si la ligne n’existait pas.

```ruby
Setting.fetch(:insee_password)
Setting.fetch(:insee_calls_enabled)        # => true
```

## Le code déclare, la base surcharge

Une clé n’existe que si elle est déclarée dans `Setting::DEFINITIONS`. Lire ou écrire une clé inconnue
lève `Setting::UnknownKeyError` — c’est ce qui empêche la table de devenir un tiroir fourre-tout que
plus personne ne relit en PR.

```ruby
DEFINITIONS = {
  insee_password: { type: :string, env: 'INSEE_PASSWORD', credential: %i[insee_password] },
  insee_calls_enabled: { type: :enabled_unless_false, default: true },
}.freeze
```

| Clé de déclaration | Rôle |
| -- | -- |
| `type` | `:string`, `:integer`, `:duration` (stockée en secondes), `:enabled_unless_false` |
| `env` | nom de la variable d’environnement consultée ensuite |
| `credential` | chemin dans les credentials, passé à `dig` |
| `default` | valeur si rien ne répond |

`env` et `credential` sont facultatifs : un paramètre purement opérationnel n’a qu’un `default`.

⚠️ **Le `default` n’est pas passé par `cast`** : il est renvoyé tel quel. Il doit donc déjà être du type
annoncé — `6.hours` et non `21600`, `50` et non `'50'`. Seules les valeurs venant de la base, de
l’environnement ou des credentials sont converties, parce qu’elles arrivent toujours en chaîne.

`:enabled_unless_false` est délibérément plus strict que `:boolean` : la valeur est vraie **sauf si elle
vaut exactement `"false"`**. Là où `:boolean` accepte `"0"`, `"off"` ou `""` comme faux,
`:enabled_unless_false` les considère comme vrais. C’est le bon type pour un interrupteur qui coupe la
production : une faute de frappe ne doit ni couper ni rouvrir par accident.

## Depuis la console

```ruby
Setting.fetch(:insee_password)             # lire, chaîne complète
Setting.set(:insee_password, '…')          # surcharger
Setting.unset(:insee_password)             # revenir à la chaîne
Setting.overridden_keys                    # ce que la base surcharge réellement
```

Une écriture est visible **immédiatement par tous les process** : `Setting` mémoïse ses valeurs et
versionne ce cache avec un `Kredis.counter`, sur le motif de `StaticApplicationRecord`. Sans ça, un
worker Puma garderait la valeur d’avant indéfiniment.

## Ce que ça ne remplace pas

- **Les valeurs lues au boot.** `config/initializers/sentry.rb`, `omniauth.rb` et `mailjet.rb` lisent
  avant que la base soit disponible. Elles restent en credentials. Le précédent est
  `dynamic_authorization_types.rb`, obligé de se protéger par `table_exists?` pour ne pas casser un
  `db:create`.
- **L’amorçage.** `DATABASE_URL` et les clés de chiffrement ne peuvent pas vivre dans la base.
- **`FeatureFlag`.** Ses règles sont des lambdas, pas des valeurs : `user&.admin?` ne se range pas dans
  une ligne. Seuls les drapeaux qui sont de vraies valeurs pourraient migrer ici, plus tard.

## Sécurité

La colonne `value` est chiffrée (`encrypts :value, deterministic: false`), comme `Webhook#secret`. Deux
conséquences voulues :

- un dump de production restauré ailleurs ne livre pas les valeurs ;
- Rails ajoute automatiquement les attributs chiffrés à `filter_parameters`, donc `value` n’apparaît ni
  dans `inspect` ni dans les logs. `Setting.fetch` et `record.value` renvoient bien la valeur réelle.

L’écriture se fait en console, dont l’accès est déjà restreint à ceux qui ont le SSH vers `watchdoge` —
un périmètre plus étroit que les admins DataPass. **Le jour où une UI d’admin est ajoutée**, il faudra
rétablir la distinction secret / non secret dans `DEFINITIONS` et n’exposer que les secondes : le
stockage étant uniforme, rien ne l’impose aujourd’hui.

## Ordre de déploiement

`Setting` fonctionne avant que sa migration ait tourné : si la table n’existe pas, la chaîne reprend à
la variable d’environnement. Le code peut donc partir avant la migration sans rien casser, et se répare
tout seul dès qu’elle est passée.

**Seule l’absence de table est rattrapée.** Toute autre erreur SQL — timeout, transaction avortée,
connexion coupée — **remonte**. C’est volontaire : `insee_calls_enabled` a `true` pour défaut, donc
avaler un hoquet de base rouvrirait silencieusement les appels INSEE au pire moment. Une lecture qui
échoue doit échouer bruyamment, pas rendre la main au défaut.

Pour la même raison, une ligne que l’environnement ne sait pas déchiffrer — un dump de production
restauré ailleurs, exactement le scénario que le chiffrement protège — est **ignorée individuellement**
et signalée à Sentry, au lieu de faire tomber toutes les clés avec elle.
