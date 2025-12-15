# Documentation des Webhooks DataPass

## Table des matières

1. [Introduction](#introduction)
2. [Prérequis : Rôle développeur](#prérequis--rôle-développeur)
3. [Gestion des webhooks via l'interface](#gestion-des-webhooks-via-linterface)
4. [API REST pour interroger l'historique](#api-rest-pour-interroger-lhistorique)
5. [Architecture technique](#architecture-technique)
6. [Implémentation côté récepteur](#implémentation-côté-récepteur)
7. [Format des événements et du payload](#format-des-événements-et-du-payload)
8. [Sécurité et authentification](#sécurité-et-authentification)
9. [Gestion des échecs et retry](#gestion-des-échecs-et-retry)
10. [Migration depuis l'ancien système](#migration-depuis-lancien-système)

---

## Introduction

DataPass propose un système de webhooks permettant de recevoir des notifications en temps réel sur les événements liés aux demandes d'habilitation. Ce système remplace l'ancien mécanisme basé sur des variables d'environnement et offre une gestion complète via une interface web et une API REST.

### Fonctionnalités principales

- **Gestion autonome** : Créez et gérez vos webhooks via l'interface développeur
- **Webhooks multiples** : Possibilité de créer plusieurs webhooks par type d'habilitation, sans limitation
- **Souscription aux événements** : Choisissez précisément les événements à écouter (create, submit, approve, etc.)
- **Historique complet** : Consultez tous les appels effectués avec leurs statuts, codes HTTP et réponses
- **Rejeu manuel** : Rejouez un appel qui a échoué directement depuis l'interface
- **Test automatique** : Les webhooks sont automatiquement testés lors de leur création
- **Désactivation automatique** : Les webhooks défaillants sont automatiquement désactivés après 5 échecs consécutifs
- **API de polling** : Interrogez l'historique des appels via l'API REST avec filtres temporels

---

## Prérequis : Rôle développeur

**Important** : La gestion des webhooks nécessite d'avoir le rôle **développeur** pour un ou plusieurs types d'habilitation.

### Comment obtenir le rôle développeur ?

Le rôle développeur doit être attribué manuellement par un administrateur DataPass. Ce rôle vous donne accès à :

- L'espace développeur : `/developpeurs`
- La gestion des webhooks : `/developpeurs/webhooks`
- L'API REST pour interroger l'historique des appels
- Les applications OAuth pour l'authentification API

### Vérifier vos droits

Vous pouvez vérifier vos rôles développeur en vous connectant à DataPass et en accédant à votre profil. Les types d'habilitation pour lesquels vous avez le rôle développeur y sont listés.

---

## Gestion des webhooks via l'interface

### Accéder à l'espace développeur

1. Connectez-vous à DataPass
2. Accédez à `/developpeurs`
3. Cliquez sur "Gérer les webhooks"

### Créer un nouveau webhook

1. Depuis `/developpeurs/webhooks`, cliquez sur "Nouveau webhook"
2. Renseignez les informations suivantes :
   - **Type d'habilitation** : Sélectionnez le type pour lequel vous souhaitez créer un webhook (uniquement les types pour lesquels vous avez le rôle développeur)
   - **URL** : L'URL de votre endpoint qui recevra les notifications (doit être accessible publiquement)
   - **Secret** : Un token de sécurité que vous générez (utilisé pour signer les requêtes avec HMAC-SHA256)
   - **Événements** : Cochez au moins un événement à écouter (obligatoire)

3. **Test automatique** : Le système teste automatiquement votre webhook en envoyant un payload de test
   - Si le test réussit (code HTTP 200), le webhook est créé et marqué comme valide
   - Si le test échoue, le webhook est créé mais reste invalide et désactivé

4. **Activation** : Une fois le webhook valide, vous pouvez l'activer via le bouton "Activer"

### Les événements disponibles

Vous pouvez souscrire aux événements suivants (sélection multiple possible) :

- `create` : Une nouvelle demande d'habilitation a été créée
- `update` : Une demande d'habilitation a été mise à jour par le demandeur
- `submit` : Une demande d'habilitation a été soumise pour instruction
- `approve` : Une demande d'habilitation a été validée par un instructeur
- `refuse` : Une demande d'habilitation a été refusée
- `revoke` : Une habilitation a été révoquée
- `request_changes` : Un instructeur demande des modifications au demandeur
- `archive` : Une demande d'habilitation a été archivée
- `reopen` : Une habilitation a été réouverte par le demandeur
- `cancel_reopening` : Une demande de réouverture a été annulée
- `transfer` : Une demande d'habilitation a été transférée à une autre organisation

**Note** : Les événements `start_next_stage` et `cancel_next_stage` (liés aux habilitations multi-étapes) ne déclenchent pas de webhooks.

### Modifier un webhook

1. Depuis la liste des webhooks, cliquez sur "Modifier"
2. Modifiez les champs souhaités
3. **Si vous modifiez l'URL ou le secret** :
   - Le webhook est automatiquement désactivé
   - Un nouveau test est effectué
   - Si le test réussit, le webhook redevient valide (mais reste désactivé, vous devez le réactiver manuellement)
   - Si le test échoue, le webhook reste invalide et désactivé

4. **Si vous modifiez uniquement les événements** :
   - Le webhook est automatiquement désactivé
   - Vous devez le réactiver manuellement

### Activer / Désactiver un webhook

- **Activer** : Le webhook doit être marqué comme valide (test réussi). Cliquez sur "Activer" depuis la liste ou la page de détails.
- **Désactiver** : Cliquez sur "Désactiver" depuis la liste ou la page de détails. Le webhook ne recevra plus d'notifications.

### Tester manuellement un webhook

Vous pouvez tester manuellement un webhook à tout moment :

1. Depuis la page de détails du webhook, cliquez sur "Tester"
2. Un payload de test est envoyé à votre endpoint
3. Le résultat du test (code HTTP et extrait de la réponse) est affiché
4. Si le test réussit, le webhook est marqué comme valide

### Consulter l'historique des appels

1. Depuis la liste des webhooks, cliquez sur "Voir les appels"
2. L'historique affiche tous les appels effectués avec :
   - Date et heure
   - Événement déclenché
   - Code de statut HTTP
   - Indicateur de succès/échec
   - Lien vers la demande d'habilitation concernée

3. Cliquez sur un appel pour voir les détails complets :
   - Payload envoyé (JSON complet)
   - Code de statut HTTP
   - Réponse du serveur (limitée à 10 000 caractères)
   - Possibilité de rejouer l'appel

### Rejouer un appel échoué

Si un appel webhook a échoué, vous pouvez le rejouer :

1. Depuis les détails d'un appel, cliquez sur "Rejouer"
2. Un nouvel appel est effectué avec le même payload
3. Le nouvel appel apparaît dans l'historique

**Note** : Vous ne pouvez rejouer un appel que si le webhook est actif.

### Créer plusieurs webhooks

Vous pouvez créer **plusieurs webhooks pour un même type d'habilitation**, sans limitation de nombre. Cela permet par exemple de :

- Notifier plusieurs systèmes différents
- Séparer les notifications par environnement (dev, staging, production)
- Tester un nouveau webhook sans désactiver l'ancien

---

## API REST pour interroger l'historique

### Authentification

L'API utilise OAuth 2.0 pour l'authentification. Vous devez :

1. Créer une application OAuth depuis `/developpeurs/applications`
2. Obtenir un access token avec le scope `read_webhooks`
3. Utiliser ce token dans le header `Authorization: Bearer {token}`

### Endpoint : GET /api/v1/webhooks/:webhook_id/attempts

Récupère l'historique des appels d'un webhook spécifique.

#### Paramètres

- `webhook_id` (path, requis) : ID du webhook
- `start_time` (query, optionnel) : Date de début au format ISO 8601 (ex: `2024-01-01T00:00:00Z`)
- `end_time` (query, optionnel) : Date de fin au format ISO 8601
- `limit` (query, optionnel) : Nombre d'appels à retourner (par défaut 100, maximum 100)

#### Exemple de requête

```bash
curl -X GET "https://datapass.api.gouv.fr/api/v1/webhooks/123/attempts?start_time=2024-01-01T00:00:00Z&end_time=2024-01-31T23:59:59Z&limit=50" \
  -H "Authorization: Bearer YOUR_OAUTH_TOKEN"
```

#### Format de réponse

```json
[
  {
    "id": 456,
    "event": "approve",
    "status_code": 200,
    "response_body": "{\"success\": true}",
    "created_at": "2024-01-15T10:30:00Z",
    "authorization_request_id": 789
  },
  {
    "id": 457,
    "event": "submit",
    "status_code": 500,
    "response_body": "{\"error\": \"Internal Server Error\"}",
    "created_at": "2024-01-15T11:00:00Z",
    "authorization_request_id": 790
  }
]
```

#### Codes de réponse

- `200 OK` : Liste des appels retournée avec succès
- `401 Unauthorized` : Token OAuth invalide ou manquant
- `403 Forbidden` : Le scope `read_webhooks` est manquant
- `404 Not Found` : Webhook introuvable ou vous n'avez pas accès à ce webhook

---

## Architecture technique

### Modèle de données

#### Table `webhooks`

| Champ                       | Type     | Description                                                    |
|-----------------------------|----------|----------------------------------------------------------------|
| `id`                        | integer  | Identifiant unique                                             |
| `authorization_definition_id` | string   | Type d'habilitation (ex: `api_entreprise`, `api_particulier`) |
| `url`                       | string   | URL de destination                                             |
| `events`                    | jsonb    | Liste des événements souscrits (array JSON)                    |
| `secret`                    | text     | Token de sécurité (chiffré avec Rails encrypted attributes)    |
| `enabled`                   | boolean  | Webhook actif (par défaut: `false`)                            |
| `validated`                 | boolean  | Webhook validé par un test réussi (par défaut: `false`)        |
| `activated_at`              | datetime | Date de première validation réussie                            |
| `created_at`                | datetime | Date de création                                               |
| `updated_at`                | datetime | Date de dernière modification                                  |

#### Table `webhook_attempts`

| Champ                     | Type     | Description                                                |
|---------------------------|----------|------------------------------------------------------------|
| `id`                      | integer  | Identifiant unique                                         |
| `webhook_id`              | integer  | Référence au webhook                                       |
| `authorization_request_id` | integer  | Référence à la demande d'habilitation                      |
| `event_name`              | string   | Nom de l'événement déclenché                               |
| `status_code`             | integer  | Code HTTP de la réponse (nullable si timeout/erreur)       |
| `response_body`           | text     | Corps de la réponse (limité à 10 000 caractères)          |
| `payload`                 | jsonb    | Payload envoyé (JSON complet)                              |
| `created_at`              | datetime | Date et heure de l'appel                                   |

### Flux de déclenchement

```
Événement sur AuthorizationRequest
  ↓
DeliverAuthorizationRequestNotification (Interactor)
  ↓
Récupère tous les webhooks actifs pour cet événement
  ↓
Pour chaque webhook :
  ↓
  DeliverAuthorizationRequestWebhookJob (Sidekiq Job)
    ↓
    WebhookHttpService (calcul HMAC + appel HTTP)
      ↓
      SaveWebhookAttempt (enregistrement de l'appel)
        ↓
        Si échec ET 5ème tentative :
          → Désactivation du webhook
          → Envoi email aux développeurs
```

### Services et interactors

- **WebhookHttpService** : Service partagé pour calculer le HMAC-SHA256 et effectuer l'appel HTTP
- **Developer::SaveWebhookAttempt** : Enregistre chaque appel dans la base de données
- **Developer::CreateWebhook** : Crée et teste un nouveau webhook
- **Developer::UpdateWebhook** : Met à jour et re-teste si nécessaire
- **Developer::EnableWebhook** : Active un webhook (uniquement si valide)
- **Developer::ReplayWebhookAttempt** : Rejoue un appel échoué
- **DeliverAuthorizationRequestWebhookJob** : Job Sidekiq pour l'envoi asynchrone

---

## Implémentation côté récepteur

### Prérequis

Votre endpoint webhook doit :

1. **Être accessible publiquement** via HTTPS
2. **Répondre rapidement** (timeout de 10 secondes)
3. **Retourner un code HTTP de succès** : `200`, `201` ou `204`
4. **Vérifier la signature HMAC** (obligatoire pour la sécurité)

### Format de la requête

DataPass effectue une requête HTTP POST vers votre URL avec :

**Headers** :
- `Content-Type: application/json`
- `X-Hub-Signature-256: sha256=<signature_hmac>`
- `X-App-Environment: <environment>` (valeurs possibles : `sandbox`, `staging`, `production`)

**Body** : JSON contenant l'événement et les données de la demande d'habilitation

### Exemple de payload

```json
{
  "event": "approve",
  "fired_at": 1628253953,
  "model_type": "authorization_request/api_entreprise",
  "data": {
    "id": 9001,
    "public_id": "a90939e8-f906-4343-8996-5955257f161d",
    "state": "validated",
    "form_uid": "api-entreprise-demande-libre",
    "organization": {
      "id": 9002,
      "name": "UMAD CORP",
      "siret": "98043033400022"
    },
    "applicant": {
      "id": 9003,
      "email": "jean.dupont@beta.gouv.fr",
      "given_name": "Jean",
      "family_name": "Dupont",
      "phone_number": "0836656565",
      "job_title": "Rockstar"
    },
    "data": {
      "intitule": "Ma demande",
      "scopes": ["cnaf_identite", "cnaf_enfants"],
      "contact_technique_given_name": "Tech",
      "contact_technique_family_name": "Os",
      "contact_technique_phone_number": "08366666666",
      "contact_technique_job_title": "DSI",
      "contact_technique_email": "tech@beta.gouv.fr"
    }
  }
}
```

### Description des champs

- **`event`** (string) : Nom de l'événement (`create`, `update`, `submit`, `approve`, etc.)
- **`fired_at`** (timestamp) : Horodatage Unix du moment où le webhook a été déclenché
- **`model_type`** (string) : Type de la demande (format snake_case, ex: `authorization_request/api_particulier`)
- **`data`** (object) : Données complètes de la demande d'habilitation (voir le serializer `WebhookAuthorizationRequestSerializer`)

---

## Sécurité et authentification

### Vérification de la signature HMAC

**⚠️ IMPORTANT** : Vous **devez** vérifier la signature HMAC pour garantir que la requête provient bien de DataPass. Ne pas le faire expose votre système à des attaques.

### Comment vérifier la signature

1. Récupérez le header `X-Hub-Signature-256`
2. Récupérez le corps brut de la requête (sans parsing)
3. Calculez le HMAC-SHA256 avec votre secret
4. Comparez les deux valeurs de manière sécurisée

### Exemple d'implémentation (Ruby/Rails)

```ruby
def verify_webhook_signature
  hub_signature = request.headers['X-Hub-Signature-256']
  payload_body = request.raw_post
  verify_token = ENV['DATAPASS_WEBHOOK_SECRET']

  computed_signature = 'sha256=' + OpenSSL::HMAC.hexdigest(
    OpenSSL::Digest.new('sha256'),
    verify_token,
    payload_body
  )

  unless Rack::Utils.secure_compare(hub_signature, computed_signature)
    head :unauthorized
    return
  end

  # Signature valide, traiter la requête
end
```

### Exemple d'implémentation (Node.js/Express)

```javascript
const crypto = require('crypto');

function verifyWebhookSignature(req, res, next) {
  const hubSignature = req.headers['x-hub-signature-256'];
  const secret = process.env.DATAPASS_WEBHOOK_SECRET;

  const computedSignature = 'sha256=' + crypto
    .createHmac('sha256', secret)
    .update(req.rawBody) // Assurez-vous d'avoir accès au body brut
    .digest('hex');

  if (!crypto.timingSafeEqual(
    Buffer.from(hubSignature),
    Buffer.from(computedSignature)
  )) {
    return res.status(401).send('Invalid signature');
  }

  next();
}
```

### Exemple d'implémentation (Python/Flask)

```python
import hmac
import hashlib
from flask import request

def verify_webhook_signature():
    hub_signature = request.headers.get('X-Hub-Signature-256')
    secret = os.environ['DATAPASS_WEBHOOK_SECRET'].encode()
    payload_body = request.get_data()

    computed_signature = 'sha256=' + hmac.new(
        secret,
        payload_body,
        hashlib.sha256
    ).hexdigest()

    if not hmac.compare_digest(hub_signature, computed_signature):
        return False, 401

    return True, 200
```

### Tester votre webhook avec webhook.site

Pour tester rapidement votre implémentation sans développer un endpoint complet :

1. Allez sur [https://webhook.site](https://webhook.site)
2. Copiez l'URL unique générée
3. Créez un webhook dans DataPass avec cette URL
4. Déclenchez un événement dans DataPass
5. Consultez la requête reçue sur webhook.site (payload, headers, signature)

**Note** : webhook.site ne vérifie pas la signature HMAC. Utilisez-le uniquement pour les tests de développement.

---

## Gestion des échecs et retry

### Codes HTTP de succès

DataPass considère les codes HTTP suivants comme des succès :
- `200 OK`
- `201 Created`
- `204 No Content`

Tout autre code (4xx, 5xx) ou timeout est considéré comme un échec.

### Stratégie de retry

En cas d'échec, DataPass utilise un **backoff polynomial** pour réessayer l'envoi :

| Tentative | Délai avant prochain essai | Temps cumulé     |
|-----------|----------------------------|------------------|
| 1         | 20 secondes                | 20s              |
| 2         | 26 secondes                | 46s              |
| 3         | 46 secondes                | 1m 32s           |
| 4         | 1m 56s                     | 3m 28s           |
| 5         | 4m 56s                     | 8m 24s           |
| ...       | ...                        | ...              |

*(voir la table complète dans la documentation technique)*

### Désactivation automatique après 5 échecs

Après **5 tentatives échouées consécutives**, le webhook est automatiquement :

1. **Désactivé** : Il ne recevra plus de notifications
2. **Email de notification** : Tous les développeurs du type d'habilitation reçoivent un email contenant :
   - Le type d'habilitation concerné
   - L'URL du webhook
   - Le dernier code d'erreur HTTP
   - Un lien direct vers la gestion du webhook

### Réactivation après désactivation

Pour réactiver un webhook désactivé automatiquement :

1. Vérifiez et corrigez le problème sur votre endpoint
2. Testez le webhook manuellement depuis l'interface
3. Si le test réussit, activez le webhook
4. Les nouvelles notifications seront à nouveau envoyées

---

## Format des événements et du payload

### États possibles d'une demande d'habilitation

Une demande d'habilitation peut avoir les états suivants (champ `state`) :

- `draft` : Brouillon, en cours de rédaction par le demandeur
- `submitted` : Soumise pour instruction
- `changes_requested` : Modifications demandées par un instructeur
- `validated` : Validée par un instructeur (habilitation créée)
- `refused` : Refusée
- `revoked` : Révoquée
- `archived` : Archivée

### Événement spécial : `approve` avec token_id

Lors de l'événement `approve` (validation d'une habilitation), votre système peut répondre avec un identifiant de jeton qui sera enregistré dans DataPass.

**Format de réponse attendu** :

```json
{
  "token_id": "1234567890asdfghjkl"
}
```

Ce `token_id` sera stocké dans le champ `external_provider_id` de l'habilitation et peut servir de référence entre DataPass et votre système.

### Serializer utilisé

Le payload complet est généré par le serializer `WebhookSerializer` qui utilise `WebhookAuthorizationRequestSerializer`. Vous pouvez consulter ces fichiers dans le code source pour voir tous les champs disponibles.

---

## Migration depuis l'ancien système

### Ancien système (variables d'environnement)

Avant 2025, les webhooks étaient configurés via des variables d'environnement :

```
API_ENTREPRISE_WEBHOOK_URL=https://...
API_ENTREPRISE_VERIFY_TOKEN=secret_token
```

Et gérés directement dans des notifiers spécifiques.

### Nouveau système (base de données)

Depuis 2025, les webhooks sont :

- Stockés en base de données
- Gérables via l'interface développeur
- Associés à un utilisateur avec le rôle développeur
- Consultables et rejouables depuis l'historique

### Migration automatique

Les webhooks configurés via variables d'environnement ont été migrés automatiquement lors du déploiement. Les anciennes variables ne sont plus utilisées mais sont conservées dans les credentials pour référence.

**Webhooks migrés** :

- `api_entreprise` : Tous les événements (sauf start_next_stage, cancel_next_stage)
- `api_particulier` : Tous les événements (sauf start_next_stage, cancel_next_stage)
- `formulaire_qf` : Tous les événements (sauf start_next_stage, cancel_next_stage)
- `annuaire_des_entreprises` : Événement `approve` uniquement

Ces webhooks ont été créés avec le statut `enabled: true` et `validated: true`.

### Nettoyage du code

Les appels directs à `webhook_notification` dans les notifiers spécifiques ont été supprimés. La logique webhook est maintenant centralisée dans `DeliverAuthorizationRequestNotification` qui boucle sur tous les webhooks actifs pour un événement donné.

---

## Support et contact

Pour toute question sur l'utilisation des webhooks :

- Documentation API : `/developpeurs/documentation`
- Issues GitHub : [github.com/betagouv/datapass](https://github.com/betagouv/datapass)
- Contact : datapass@api.gouv.fr

Pour obtenir le rôle développeur, contactez un administrateur DataPass.
