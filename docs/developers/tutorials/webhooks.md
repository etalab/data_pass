# Tutoriel : suivre les demandes via webhooks

Les webhooks permettent d'être **notifié en temps réel** des changements d'état d'une demande d'habilitation, sans avoir à interroger régulièrement l'API. Ils sont complémentaires des endpoints de lecture et d'écriture.

## Prérequis

- Avoir le rôle **« développeur »** pour le type d'habilitation concerné (sans ce rôle, l'interface de création de webhooks n'est pas accessible).
- Disposer d'un endpoint HTTPS public capable de recevoir un `POST` JSON et de répondre `200` en moins de quelques secondes.

La documentation exhaustive (événements, signature HMAC, retry, désactivation automatique) est disponible sur la page [Documentation des webhooks](/developpeurs/webhooks/documentation). Ce tutoriel se concentre sur les cas d'usage d'intégration.

## Cas d'usage : suivre le cycle de vie des demandes

Scénario : un agent soumet une demande via votre CRM (créée par API), vous voulez recevoir les événements `submit`, `approve`, `refuse`, `request_changes` pour mettre à jour le dossier côté CRM.

### 1. Créer le webhook depuis l'interface

Rendez-vous sur [/developpeurs/webhooks](/developpeurs/webhooks) et créez un webhook :

- **Type d'habilitation** : le type pour lequel vous voulez recevoir les événements (limité aux types où vous avez le rôle développeur).
- **URL** : l'URL HTTPS publique de votre endpoint.
- **Événements** : cochez `submit`, `approve`, `refuse`, `request_changes` (par exemple).

Un **test automatique** est envoyé à la création : si votre endpoint ne répond pas `200`, le webhook est créé désactivé.

Un **secret** est affiché une seule fois après création. Stockez-le dans votre coffre de secrets, il sert à vérifier la signature des appels reçus.

### 2. Recevoir et vérifier les appels

Chaque appel est un `POST` JSON contenant l'événement et la demande associée. Il est signé via HMAC-SHA256 dans l'en-tête `X-Hub-Signature-256`.

Exemple de payload reçu pour un événement `approve` :

```json
{
  "event": "approve",
  "occurred_at": "2026-04-22T10:15:32Z",
  "data": {
    "id": 123,
    "public_id": "D123",
    "type": "api_entreprise",
    "state": "validated",
    "applicant": { "email": "demandeur@mairie-exemple.fr" },
    "organization": { "siret": "13002526500013" }
  }
}
```

Le schéma détaillé (champs complets de la demande, événements spécifiques) est dans la [documentation webhooks](/developpeurs/webhooks/documentation).

#### En Ruby (Rails / Sinatra)

```ruby
require 'openssl'

class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def datapass
    payload = request.raw_post
    signature = request.headers['X-Hub-Signature-256'].to_s
    expected = 'sha256=' + OpenSSL::HMAC.hexdigest('sha256', ENV.fetch('DATAPASS_WEBHOOK_SECRET'), payload)

    if signature.bytesize != expected.bytesize ||
       !ActiveSupport::SecurityUtils.fixed_length_secure_compare(signature, expected)
      head :unauthorized and return
    end

    event = JSON.parse(payload)

    case event['event']
    when 'submit'   then MettreAJourDossier.call(event['data'], statut: 'soumis')
    when 'approve'  then MettreAJourDossier.call(event['data'], statut: 'valide')
    when 'refuse'   then MettreAJourDossier.call(event['data'], statut: 'refuse')
    when 'request_changes' then NotifierAgent.call(event['data'])
    end

    head :ok
  end
end
```

> `ActiveSupport::SecurityUtils.secure_compare` lève `ArgumentError` si les deux chaînes n'ont pas la même taille. Un appel sans en-tête `X-Hub-Signature-256` (ou avec une valeur tronquée) ferait alors remonter une `500` à la place d'une `401`. On garde un contrôle de taille explicite avant `fixed_length_secure_compare`.

#### En Python (Flask)

```python
import hmac, hashlib, os
from flask import Flask, request, abort

app = Flask(__name__)
SECRET = os.environ['DATAPASS_WEBHOOK_SECRET'].encode()

@app.post('/webhooks/datapass')
def datapass():
    signature = request.headers.get('X-Hub-Signature-256', '')
    expected = 'sha256=' + hmac.new(SECRET, request.data, hashlib.sha256).hexdigest()

    if not hmac.compare_digest(signature, expected):
        abort(401)

    event = request.get_json()
    # dispatch selon event['event']
    return '', 200
```

#### En Node.js (Express)

> **Ordre des middlewares Express** : si `app.use(express.json())` est monté globalement en amont, le body sera déjà consommé et re-sérialisé lorsque `express.raw` s'exécute, ce qui fait échouer le HMAC. Monter la route webhook **avant** tout `express.json()` global, ou exclure ce chemin du parseur JSON.

```javascript
import express from 'express'
import crypto from 'crypto'

const app = express()

app.post(
  '/webhooks/datapass',
  express.raw({ type: 'application/json' }),
  (req, res) => {
    const expected =
      'sha256=' +
      crypto
        .createHmac('sha256', process.env.DATAPASS_WEBHOOK_SECRET)
        .update(req.body)
        .digest('hex')

    const signature = req.get('X-Hub-Signature-256') || ''

    if (
      signature.length !== expected.length ||
      !crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(expected))
    ) {
      return res.sendStatus(401)
    }

    const event = JSON.parse(req.body.toString('utf8'))
    // dispatch selon event.event
    res.sendStatus(200)
  }
)
```

> **Important** : vérifiez la signature **avant** de parser le JSON, et utilisez une comparaison constante (`secure_compare`, `hmac.compare_digest`, `timingSafeEqual`).

### 3. Répondre rapidement et traiter en asynchrone

Les webhooks attendent une réponse `2xx` sous quelques secondes. Si votre traitement est lourd (mise à jour CRM, envoi de mail), enfilez un job asynchrone et répondez `200` immédiatement.

## Cas d'usage : distinguer les événements initiés par l'API

Si votre CRM pousse des demandes via `POST /demandes` (voir [le tutoriel écriture](/developpeurs/tutoriels/ecriture)), les événements générés sont typés :

- `create_by_api` — création via l'API
- `update_by_api` — mise à jour via l'API

Concrètement : si votre système est à la fois émetteur (push vers DataPass) **et** consommateur (écoute webhooks), filtrer ces événements évite de retraiter une création que vous venez vous-même d'émettre — typique des boucles de synchronisation CRM qui se déclenchent en cascade.

## Cas d'usage : rejouer un appel en échec

L'historique des appels est visible sur [/developpeurs/webhooks](/developpeurs/webhooks) (bouton « Voir les appels ») :

- Consultez le code HTTP renvoyé et la réponse reçue.
- Rejouez manuellement un appel via le bouton « Rejouer cet appel ».
- Programmatiquement, consultez l'endpoint API `GET /webhooks/{webhook_id}/attempts` (scope `read_webhooks`). Voir la [spec OpenAPI](/developpeurs/documentation).

### Politique de retry

En cas de réponse non-2xx (ou d'absence de réponse), l'appel est rejoué automatiquement selon un back-off exponentiel. Après **5 échecs consécutifs**, le webhook est **automatiquement désactivé** — les événements suivants ne sont plus envoyés tant qu'il n'est pas réactivé manuellement depuis l'interface.

Les détails exacts (délais entre tentatives, nombre maximal de tentatives par appel, codes qui déclenchent un retry) sont dans la [documentation webhooks](/developpeurs/webhooks/documentation). Activez une alerte interne sur les codes non-2xx pour ne pas découvrir une désactivation par hasard.

## Événements disponibles

| Événement | Déclenché par |
| --- | --- |
| `create` | Création d'une demande depuis l'interface |
| `create_by_api` | Création d'une demande via l'API |
| `update` | Mise à jour d'une demande depuis l'interface |
| `update_by_api` | Mise à jour d'une demande via l'API |
| `submit` | Soumission d'une demande par le demandeur |
| `approve` | Validation par un instructeur |
| `refuse` | Refus par un instructeur |
| `request_changes` | Demande de modifications par un instructeur |
| `revoke` | Révocation d'une habilitation |
| `archive` | Archivage |
| `reopen` | Réouverture d'une demande clôturée |
| `cancel_reopening` | Annulation d'une réouverture |
| `transfer` | Transfert à une autre organisation |

La liste complète, le format détaillé du payload, la politique de retry et les bonnes pratiques de sécurité sont dans la [documentation des webhooks](/developpeurs/webhooks/documentation).

### Correspondance événement ↔ état

Les noms d'événements ne reprennent pas toujours le nom de l'état cible de la demande. Référentiel utile quand vous enchaînez lecture (`state`) et webhooks (`event`) :

| Événement | État résultant de la demande |
| --- | --- |
| `submit` | `submitted` |
| `approve` | `validated` |
| `refuse` | `refused` |
| `request_changes` | `changes_requested` |
| `archive` | `archived` |
| `revoke` | `revoked` (côté habilitation) |
| `create` / `create_by_api` | `draft` |
| `update` / `update_by_api` | inchangé |

Le détail complet du cycle de vie est documenté dans [lifecycle_documentation.md](https://github.com/etalab/data_pass/blob/main/docs/lifecycle_documentation.md).

## Aller plus loin

- [Documentation complète des webhooks](/developpeurs/webhooks/documentation)
- [Mes webhooks](/developpeurs/webhooks)
- [Documentation OpenAPI](/developpeurs/documentation)
- [Tutoriel : exploiter l'API en lecture](/developpeurs/tutoriels/lecture)
- [Tutoriel : exploiter l'API en écriture](/developpeurs/tutoriels/ecriture)
