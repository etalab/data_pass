# Synchronisation des habilitations DataPass vers data.gouv.fr

## Rôle

Le job `DatagouvHabilitationsSyncJob` met à jour le jeu de données [Habilitations Datapass validées](https://www.data.gouv.fr/datasets/habilitations-datapass-validees) sur data.gouv.fr avec la liste des **habilitations actives** (et non des demandes au statut « validé »).

Une demande peut être en brouillon de réouverture tout en ayant des habilitations actives ; le CSV reflète les habilitations actuellement actives.

## Fréquence

Le job est planifié en **production uniquement** : exécution le 1er de chaque mois à 2 h (cron : `0 2 1 * *`).

En staging et sandbox, le job n’est pas planifié ; des tests manuels sont possibles en pointant la configuration vers `https://demo.data.gouv.fr/api/1` et le dataset démo [habilitations-datapass-validees](https://demo.data.gouv.fr/datasets/habilitations-datapass-validees).

## Configuration

La configuration est lue depuis les **Rails credentials** sous la clé `data_gouv_fr` :

- `api_key` (obligatoire en production) : clé API data.gouv.fr (compte DINUM ou dédié) avec droits d’édition sur le dataset.
- `base_url` (optionnel) : URL de base de l’API (défaut : `https://www.data.gouv.fr/api/1`). En staging/sandbox, utiliser `https://demo.data.gouv.fr/api/1` pour les tests.
- `dataset_slug` (optionnel) : slug ou id du dataset (défaut : `habilitations-datapass-validees`).
- `resource_id` (optionnel) : id de la ressource CSV à mettre à jour (défaut : `da9ef212-0df6-4703-bf98-187c79d31a60`).

### Ajout de la clé API dans les credentials

À faire manuellement pour la production (et optionnellement pour démo/staging) :

1. Créer ou utiliser un compte data.gouv.fr avec droits d’édition sur le dataset « Habilitations Datapass validées ».
2. Générer une clé API dans les paramètres du compte.
3. Ajouter la clé dans les credentials Rails :

   ```bash
   EDITOR=nano rails credentials:edit
   ```

   Puis ajouter (ou compléter) :

   ```yaml
   data_gouv_fr:
     api_key: VOTRE_CLE_API
     base_url: https://www.data.gouv.fr/api/1   # optionnel en prod
     dataset_slug: habilitations-datapass-validees
     resource_id: da9ef212-0df6-4703-bf98-187c79d31a60
   ```

## Test manuel

En staging ou sandbox, après avoir configuré `base_url` (et éventuellement `dataset_slug` / `resource_id`) vers la démo et une clé API valide sur demo.data.gouv.fr :

```bash
rails runner "DatagouvHabilitationsSyncJob.perform_now"
```

Vérifier sur data.gouv.fr (ou demo.data.gouv.fr) que le fichier et la date de mise à jour du jeu de données sont corrects.
