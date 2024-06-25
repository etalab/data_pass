# Migration de l'ancienne stack

## 1. Récupération des données SQL de la v1

1. Récupérez le mot de passe de la base de donnéees de production depuis
   `very_ansible` et déposez le dans `./app/migration/.v1-pgpassword`
2. Lancer `./app/migration/export_v1.sh` (voir pour modifier le `user` dans le
   script)

## 2. LOCAL Importation des données

Executez la commande: `./app/migration/local_run.sh`
Cette commande est idempotent.

Pour clean la db locale: `./app/migration/clean_local_db.sh`

Il possible d'effectuer des filtrages sur les données importées (via les options
globale de la classe principale [`MainImport`](./main_import.rb))

De plus chaque héritant de `Import::Base` peuvent utiliser les options
suivantes:

* `dump_sql`, dump un fichier sql ;
* `load_from_sql`, load depuis un fichier sql (plus rapide).
* `TABLE_NAME_filter`, lambda pour filtrer les entrées

Chaque type d'habilitation s'occupe de ses propres attributs dans la classe
situé dans le dossier [`app/migration/import/authorization_requests/`](./import/authorization_requests),
cela permet de simplifier les traitements. La classe
`Import::AuthorizationRequests` s'occupe des attributs communs.

Pour l'import final il faure les creds d'OVH S3 dans le fichier `.ovh.yml` sous le format suivant:

```yaml
---
OVH_BUCKET: OVH_BUCKET
OVH_ACCESS_KEY_ID: OVH_ACCESS_KEY_ID
OVH_SECRET_ACCESS_KEY: OVH_SECRET_ACCESS_KEY
OVH_REGION: reg
```

### 2.1 Ajout d'un nouveau type d'habilitation.

1. Ajouter le mapping dans `Import::AuthorizationRequests#from_target_api_to_type`
2. Créer la classe spécifique pour le traitement des infos de ce type
   d'habilitation dans `app/migration/import/authorization_requests/`

## Infos sur les données exclues/retravaillées

1. Les brouillons d'avant le 01/01/2022
2. Dans les users, certains sont ajoutés à des organisations (mapping: id => sirets)
3. Dans les demandes d'autorisations, certaines organisations sont fermées ou
   ont migrées (mapping: old_siret => new_siret)
4. Certaines demandes dont les sirets ne sont pas des sirets (TBD qu'est-ce
   qu'on fait ici ?)

## 3. Import en remote

Ref https://pad.incubateur.net/xMY2MVZ1STexUrU8yfYMng

### 3.1 Initialisation

1. Déploiement du code sur la machine
2. Setup des variables (cf I.)

Le script (en local):

```
./app/migration/deploy.sh
```

Cela copie:

* `app/migration/.v1-pgpassword` Password de la database v1 ;
* `app/migration/.ovh.yml` credentials OVH v1

## 3.2 Run

Le script (à executer en remote):

(Penser à changer les variables)

```
# Staging
sudo -u root bash /var/www/datapass_reborn_staging/current/app/migration/run.sh
# Production
sudo -u root bash /var/www/datapass_reborn_production/current/app/migration/run.sh
```

Le process sur la machine distante (r) :

3. Passage du site v1 en maintenance
4. Récupération des dumps CSV
5. Création de la base de données SQLite
6. Nettoyage de la base locale
7. Execution du script de migration (`MainImport`)
8. Alteration des séquences d'ID
9. Passage de users en admin / instructeurs

ETA ~20min (le plus long reste II.r.7)
