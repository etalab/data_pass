# Tutoriel : exploiter l'API DataPass en écriture

Ce tutoriel couvre la **création** et la **mise à jour** de demandes d'habilitation via l'API. Cas d'usage typiques : ouverture d'habilitation depuis un formulaire embarqué sur votre site, synchronisation CRM → DataPass, pré-remplissage à partir d'un back-office métier.

## Prérequis

- Avoir lu [le tutoriel lecture](/developpeurs/tutoriels/lecture) pour obtenir un token OAuth2.
- Avoir le rôle **« développeur »** pour le type d'habilitation visé. Sans ce rôle, les endpoints d'écriture renvoient `403 Forbidden`.
- Demander le scope `write_authorizations` lors de la requête `/oauth/token` (en plus de `read_authorizations` si vous souhaitez aussi lire).

```ruby
response = Net::HTTP.post(
  URI('https://datapass.api.gouv.fr/api/v1/oauth/token'),
  URI.encode_www_form(
    grant_type: 'client_credentials',
    client_id: ENV.fetch('DATAPASS_CLIENT_ID'),
    client_secret: ENV.fetch('DATAPASS_CLIENT_SECRET'),
    scope: 'read_authorizations write_authorizations'
  )
)
```

## Construire la clé `data` correctement

C'est le point le plus délicat de l'API en écriture. Chaque définition d'habilitation expose la liste des clés `data` attendues via `GET /definitions/{id}`.

### Étape 1 — récupérer les clés acceptées

```python
import requests

definition = requests.get(
    'https://datapass.api.gouv.fr/api/v1/definitions/api_entreprise',
    headers={'Authorization': f'Bearer {access_token}'},
).json()

print(definition['data'])
# ['intitule', 'description', 'destinataire_donnees_caractere_personnel',
#  'duree_conservation_donnees_caractere_personnel',
#  'duree_conservation_donnees_caractere_personnel_justification',
#  'cadre_juridique_url', 'cadre_juridique_nature',
#  'date_prevue_mise_en_production', 'volumetrie_approximative', 'scopes']
```

### Étape 2 — récupérer les scopes disponibles

La clé `scopes` du payload `data` prend une liste de **valeurs techniques** issues du champ `scopes[].value` renvoyé par `GET /definitions/{id}`.

```json
{
  "scopes": [
    { "name": "Unités légales et établissements INSEE", "value": "unites_legales_etablissements_insee", "deprecated": false },
    { "name": "Bilans BDF", "value": "bilans_bdf", "deprecated": true }
  ]
}
```

Ignorez les scopes dont `deprecated` est à `true`.

### Étape 3 — construire le payload

Seules les clés listées dans `definition.data` seront acceptées. Toute clé supplémentaire est ignorée silencieusement ou produit une erreur `422` selon la définition.

## Cas d'usage : création depuis un formulaire / CRM

Scénario : un agent saisit une demande dans votre CRM ; vous la poussez vers DataPass en `draft`, puis l'agent continue sur l'interface DataPass pour soumission.

### En Node.js (depuis un backend de formulaire)

```javascript
const payload = {
  demande: {
    type: 'api_entreprise',
    applicant: {
      email: 'demandeur@mairie-exemple.fr',
      given_name: 'Jean',
      family_name: 'Dupont',
      job_title: 'Responsable informatique',
      phone_number: '0612345678'
    },
    organization: { siret: '13002526500013' },
    data: {
      intitule: 'Raccordement au référentiel INSEE',
      description: 'Pré-remplissage des formulaires usagers',
      destinataire_donnees_caractere_personnel: 'Service informatique',
      duree_conservation_donnees_caractere_personnel: 12,
      duree_conservation_donnees_caractere_personnel_justification: 'Durée légale de conservation',
      cadre_juridique_url: 'https://example.gouv.fr/arrete-123',
      cadre_juridique_nature: 'arrete',
      date_prevue_mise_en_production: '2026-06-01',
      volumetrie_approximative: 10000,
      scopes: ['unites_legales_etablissements_insee']
    }
  }
}

const response = await fetch('https://datapass.api.gouv.fr/api/v1/demandes', {
  method: 'POST',
  headers: {
    Authorization: `Bearer ${accessToken}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(payload)
})

const demande = await response.json()
// demande.id, demande.public_id, demande.state === 'draft'
```

### En Python (synchronisation depuis un CRM)

```python
import requests

payload = {
    'demande': {
        'type': 'api_entreprise',
        'applicant': {
            'email': contact['email'],
            'given_name': contact['prenom'],
            'family_name': contact['nom'],
        },
        'organization': {'siret': contact['siret']},
        'data': {
            'intitule': dossier['intitule'],
            'description': dossier['description'],
            'scopes': dossier['scopes_selectionnes'],
            # ... autres clés dynamiquement récupérées via /definitions/{id}
        },
    }
}

response = requests.post(
    'https://datapass.api.gouv.fr/api/v1/demandes',
    headers={'Authorization': f'Bearer {access_token}'},
    json=payload,
)
response.raise_for_status()
demande = response.json()
```

### `type` ou `form_uid` ?

Ces deux clés sont mutuellement exclusives :

- **`type`** (recommandé par défaut) : identifiant du type d'habilitation, avec underscores (ex. `api_entreprise`, `api_impot_particulier`). Le formulaire par défaut du type est utilisé.
- **`form_uid`** : identifiant d'un formulaire spécifique, avec tirets (ex. `api-entreprise-socle-de-base`). À utiliser uniquement si vous ciblez un cas d'usage précis avec un formulaire distinct du formulaire par défaut.

La liste des `form_uid` existants est visible dans la [spec OpenAPI](/developpeurs/documentation) via `GET /definitions/{id}` (chaque définition expose ses formulaires).

### Réponses possibles

- `201 Created` — la demande est créée en état `draft`, la réponse contient la `Demande` complète.
- `403 Forbidden` — vous n'avez pas le rôle développeur pour ce type, ou le scope `write_authorizations` manque.
- `422 Unprocessable Content` — le payload ne respecte pas la définition.

Le format des erreurs suit la convention JSON:API. Exemple de réponse `422` :

```json
{
  "errors": [
    {
      "status": "422",
      "title": "Clé de données invalide",
      "detail": "La clé « scopes » contient une valeur non autorisée.",
      "source": { "pointer": "/data/scopes" }
    }
  ]
}
```

Le pointeur `source.pointer` cible le chemin de la clé fautive dans le payload, ce qui permet d'afficher l'erreur directement à côté du bon champ côté CRM.

Voir la [spec OpenAPI de `POST /demandes`](/developpeurs/documentation) pour la liste exhaustive.

### Précisions importantes

- Le champ `applicant.email` identifie le demandeur : s'il n'existe pas, il est créé.
- Le champ `organization.siret` identifie l'organisation : si elle n'existe pas, elle est créée et rafraîchie depuis l'INSEE de façon asynchrone.
- Fournissez soit `type` (type d'habilitation, formulaire par défaut) soit `form_uid` (identifiant d'un formulaire spécifique).
- Les demandes créées par l'API génèrent un événement `create_by_api` (utile pour filtrer vos demandes dans les webhooks).

## Cas d'usage : mise à jour programmée (CRM → DataPass)

`PATCH /demandes/{id}` permet de mettre à jour une demande **en état `draft`** depuis l'API. Les demandes déjà soumises ne sont pas modifiables via cet endpoint.

```ruby
uri = URI("https://datapass.api.gouv.fr/api/v1/demandes/#{demande_id}")

request = Net::HTTP::Patch.new(uri)
request['Authorization'] = "Bearer #{access_token}"
request['Content-Type'] = 'application/json'
request.body = {
  demande: {
    data: {
      volumetrie_approximative: 50_000,
      scopes: ['unites_legales_etablissements_insee', 'associations_rna']
    }
  }
}.to_json

Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
```

Chaque mise à jour génère un événement `update_by_api` consultable via `GET /demandes/{id}/events` ou via un webhook.

## Rediriger l'utilisateur vers sa demande

La réponse d'un `POST /demandes` réussi contient deux identifiants, qui servent à des usages **distincts** :

| Champ | URL | Usage |
| --- | --- | --- |
| `id` (numérique interne, ex. `123`) | `/demandes/{id}` | Page **authentifiée** du demandeur. Permet de **compléter, modifier et soumettre** la demande. C'est cette URL qu'il faut utiliser pour rediriger l'utilisateur depuis votre CRM. |
| `public_id` (préfixé, ex. `D123`) | `/public/demandes/{public_id}` | Page **publique en lecture seule**. Lisible, partageable par email, utile pour transmettre un lien à un tiers sans lui donner accès à l'édition. |

**Ne les interchangez pas** : `/demandes/{public_id}` échoue (la recherche utilise l'`id` numérique côté `AuthorizationRequestsController#show`), et `/public/demandes/{id}` échoue de la même manière dans l'autre sens.

### Cas 1 — rediriger l'utilisateur pour qu'il complète et soumette

C'est le cas de loin le plus fréquent : votre CRM pré-remplit la demande, l'utilisateur finalise côté DataPass.

```
https://datapass.api.gouv.fr/demandes/{id}
```

Remplacez le domaine par l'environnement ciblé :

- Production : `https://datapass.api.gouv.fr/demandes/{id}`
- Staging : `https://staging.datapass.api.gouv.fr/demandes/{id}`
- Sandbox : `https://sandbox.datapass.api.gouv.fr/demandes/{id}`

```javascript
const response = await fetch('https://datapass.api.gouv.fr/api/v1/demandes', {
  method: 'POST',
  headers: {
    Authorization: `Bearer ${accessToken}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(payload)
})

if (response.status === 201) {
  const demande = await response.json()
  const url = `https://datapass.api.gouv.fr/demandes/${demande.id}`

  return reply.redirect(url)
}
```

```ruby
if response.code == '201'
  demande = JSON.parse(response.body)
  redirect_to "https://datapass.api.gouv.fr/demandes/#{demande['id']}"
end
```

### Cas 2 — partager un lien public en lecture seule

Pour diffuser un lien de consultation (reporting, partage externe, email au demandeur pour référence), utilisez le `public_id` :

```
https://datapass.api.gouv.fr/public/demandes/{public_id}
```

Cette page est accessible sans authentification et ne permet aucune action : ni édition, ni soumission.

L'utilisateur arrive sur sa demande pré-remplie ; s'il est connecté (ou après authentification via ProConnect), il peut compléter les champs restants puis soumettre. Cela évite de dupliquer le formulaire DataPass dans votre interface — votre rôle se limite au pré-remplissage initial à partir des données déjà connues de votre CRM.

> **Pré-requis côté utilisateur** : l'email passé dans `applicant.email` doit correspondre au compte ProConnect de la personne qui sera redirigée, sinon elle ne verra pas la demande dans son espace.

## Workflow recommandé

1. **Créer** la demande en `draft` depuis votre formulaire/CRM (`POST /demandes`).
2. **Rediriger** l'utilisateur vers `https://datapass.api.gouv.fr/demandes/{id}` pour qu'il finalise et soumette.
3. **Suivre** les transitions d'état (soumission, validation, refus) via les webhooks — voir [le tutoriel webhooks](/developpeurs/tutoriels/webhooks).
4. **Synchroniser** l'habilitation délivrée dans votre système interne à réception de l'événement `approve`.

## Aller plus loin

- [Documentation OpenAPI — POST /demandes](/developpeurs/documentation)
- [Tutoriel : suivre les demandes via webhooks](/developpeurs/tutoriels/webhooks)
- [Cycle de vie d'une demande](https://github.com/etalab/data_pass/blob/main/docs/lifecycle_documentation.md)
