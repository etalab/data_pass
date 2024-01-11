# Migration de l'ancienne stack

## 1. Récupération des données SQL

1. Récupérez le mot de passe de la base de donnéees de production depuis
   `very_ansible` et déposez le dans `./app/migration/.pgpassword`
2. Lancer `./app/migration/export.sh`

## 2. LOCAL Importation des données

Executez la commande: `./app/migrations/local_import.sh`
Cette commande est idempotent.
Pour clean la db locale: `./app/migrations/clean_local_db.sh`

Il possible d'effectuer des filtrages sur les données importées (via les options
globale de la classe principale [`MainImport`](./main_import.rb))

Chaque type d'habilitation s'occupe de ses propres attributs dans la classe
situé dans le dossier [`app/migration/import/authorization_requests/`](./import/authorization_requests),
cela permet de simplifier les traitements. La classe
`Import::AuthorizationRequests` s'occupe des attributs communs.
