# Migration de l'ancienne stack

## 1. Récupération des données SQL

1. Récupérez le mot de passe de la base de donnéees de production depuis
   `very_ansible` et déposez le dans `./app/migration/.pgpassword`
2. Lancer `./app/migration/export.sh`

## 2. LOCAL Importation des données

La commande: `./app/migrations/local_import.sh`

Il possible d'effectuer des filtrages sur les données importées (via les options
globale de la classe principale [`MainImport`](./main_import.rb))
