# Tokens `local-sign-in` (staging & sandbox)

Sur les environnements sensibles, `/local-sign-in` est protégé par un token secret par
fournisseur de données (DP-1855). Ce document est le mode opératoire pour **ajouter**,
**révoquer** et **vérifier** un token.

La politique de rotation (à quelle fréquence, par qui, comment on prévient les partenaires)
n’est pas tranchée ici — voir [DPP-10](https://linear.app/pole-api/issue/DPP-10).

## Où vivent les tokens

Dans les credentials chiffrées de chaque environnement, sous forme d’un dictionnaire nommé
par fournisseur :

```yaml
local_sign_in_tokens:
  dgfip: "…"
  api_entreprise: "…"
  yeswehack: "…"
```

Chaque fournisseur a son propre token : c’est ce qui rend la révocation individuelle
possible. N’importe quel token valide de la liste déverrouille l’accès.

## Quels environnements sont protégés

| Environnement | Comportement |
| --- | --- |
| `production` | la route n’existe pas |
| `development`, `test` | ouverts tant qu’aucun token n’est configuré |
| tout le reste (`staging`, `sandbox`, review apps…) | **token valide obligatoire** |

Un environnement sensible dont la clé `local_sign_in_tokens` est absente, vide ou mal formée
est **fermé**, jamais réouvert : une erreur de saisie dans les credentials coupe l’accès au
lieu de le rendre public.

## Ajouter un token pour un fournisseur

```sh
bin/rails credentials:edit --environment staging
```

Ajouter une entrée sous `local_sign_in_tokens`, avec un secret généré aléatoirement
(`bin/rails secret` ou `openssl rand -hex 32`), puis **redéployer** l’environnement : le
fichier chiffré est embarqué dans le déploiement.

Transmettre au fournisseur le lien complet, token inclus :

```
https://staging.datapass.api.gouv.fr/local-sign-in?email=…&token=<son-token>
```

Le token n’est à fournir qu’une fois : il est ensuite mémorisé dans un cookie signé
(`local_sign_in_token`, httponly, 30 jours).

## Révoquer le token d’un fournisseur

Retirer sa clé du dictionnaire, puis redéployer. L’effet est immédiat et complet :

- son token cesse de déverrouiller l’accès (404) ;
- **les porteurs du cookie de ce fournisseur perdent aussi l’accès** — le cookie ne fait que
  rejouer le token, qui est revalidé contre les credentials à chaque requête. Il n’y a pas de
  session résiduelle de 30 jours à purger ;
- les autres fournisseurs ne sont pas affectés.

Retirer **toutes** les clés d’un environnement sensible ne le rouvre pas : il devient
inaccessible (cf. tableau ci-dessus).

## Vérifier qui utilise quel token

Chaque accès déverrouillé est journalisé :

```
[local-sign-in] accès via le token « dgfip » — email=… ip=…
```

C’est la trace à consulter avant de révoquer, pour savoir qui sera coupé.

## Tester la protection en local

```sh
bin/rails credentials:edit --environment development
```

Ajouter `local_sign_in_tokens: { test: <valeur> }` : dès qu’un token est présent,
`/local-sign-in?email=…` exige `&token=<valeur>`. Retirer la clé rétablit le bypass ouvert.
