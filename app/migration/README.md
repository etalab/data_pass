# Migration de l'ancienne stack

## 1. Récupération des données SQL

1. Récupérez le mot de passe de la base de donnéees de production depuis
   `very_ansible` et déposez le dans `./app/migration/.pgpassword`
2. Lancer `./app/migration/export.sh`
