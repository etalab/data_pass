# Inscrits « Être prévenu » du portefeuille européen

Le bloc « Être prévenu de l’ouverture du registre » de la page
`/portefeuille-europeen` enregistre une adresse et un profil
([DPP-220](https://linear.app/pole-api/issue/DPP-220)). Les inscrits vivent
dans DataPass en attendant leur migration vers Brevo
([DPP-253](https://linear.app/pole-api/issue/DPP-253)) : DataPass n’envoie
aucun message et n’appelle aucun service externe.

## Données

Table `european_wallet_subscribers` (modèle `EuropeanWalletSubscriber`) :

| Colonne | Contenu |
| -- | -- |
| `email` | Adresse normalisée (espaces retirés, minuscules) puis chiffrée par Active Record Encryption, en mode **déterministe** : l’index unique fonctionne et `find_by(email:)` retrouve un inscrit |
| `profile` | `organization`, `intermediary` ou `attestation_provider` |
| `created_at` | Date d’inscription |

Le chiffrement déterministe exige `active_record_encryption.deterministic_key`
dans les credentials de l’environnement. L’adresse est filtrée de
l’inspection du modèle et des paramètres journalisés.

Une fois le registre ouvert (`EUROPEAN_WALLET_REGISTRY_OPEN=true`), le profil
`organization` n’est plus proposé ni accepté :
`EuropeanWalletSubscriber.offered_profiles(registry_open:)`.

## Parcours

```
POST /portefeuille-europeen/inscription
  → EuropeanWalletSubscriptionsController (sans connexion, 10 envois / minute / IP)
  → SubscribeToEuropeanWalletOpening
      RejectHoneypotSubmission      champ « website » rempli → fausse confirmation, rien d’enregistré
      BuildEuropeanWalletSubscriber adresse connue → même ligne, profil mis à jour
      SaveEuropeanWalletSubscriber  validations, profil proposé, envois simultanés
  → réponse rendue dans le turbo-frame « etre-prevenu-formulaire »
```

Une erreur de la base remonte à Sentry et affiche « Votre inscription n’a
pas abouti ». La limite d’envois est comptée dans Redis
(`config.x.public_rate_limit_store`, espace `public_rate_limit`), dans
`Rails.cache` en test.

## Désinscription

Chaque inscrit a un lien signé, sans expiration :
`/portefeuille-europeen/desinscription?token=…`
(`generate_token_for(:unsubscribe)`). Le GET affiche une confirmation ; seul le
POST supprime la ligne. Un lien invalide ou déjà utilisé affiche « Vous
n’êtes plus inscrit ».

## Exporter et purger

À lancer par un développeur sur l’environnement voulu :

```
bin/rails 'european_wallet:subscribers:export[intermediary]' > intermediaires.csv
bin/rails 'european_wallet:subscribers:purge[intermediary]'
```

L’export contient `email`, `profil` (`organisation`, `intermediaire`,
`fournisseur_attestations`, les valeurs prévues par DPP-253),
`date_inscription` et `lien_desinscription`. Le fichier contient des
adresses en clair : le supprimer après usage.

La purge supprime les inscrits d’un profil après l’annonce de l’ouverture de
son parcours (RG2 de DPP-220).

## Migration vers Brevo

DPP-253 importera l’export de chaque profil dans une liste Brevo, reportera
les désinscriptions faites entre-temps, remplacera le lien signé par celui de
Brevo, puis videra la table.
