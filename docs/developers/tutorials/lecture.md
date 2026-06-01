# Tutoriel : exploiter l'API DataPass en lecture

Ce tutoriel s'adresse aux fournisseurs de données qui souhaitent **consulter** les demandes et habilitations DataPass depuis un système externe : tableau de bord de pilotage, synchronisation vers un CRM, export comptable, etc.

## Prérequis

Avant toute chose, l'utilisateur dont dépend votre application OAuth2 doit avoir le rôle **« développeur »** (`developer`) pour le ou les types d'habilitation concernés.

- Ce rôle conditionne **tout** l'accès à l'API : un utilisateur sans rôle développeur reçoit `403 Forbidden` même avec un token valide.
- Le rôle est attribué manuellement par un administrateur DataPass pour chaque type d'habilitation (ex : `api_entreprise:developer`, `api_impot_particulier:developer`).
- La liste des types sur lesquels vous avez ce rôle est consultable sur [/developpeurs/applications](/developpeurs/applications).

Une application OAuth2 est également nécessaire (un `client_id` + `client_secret`). Elle est gérée depuis [/developpeurs/applications](/developpeurs/applications).

## Obtenir un jeton d'accès

L'API utilise le flow OAuth2 `client_credentials`. Pour la lecture, demandez le scope `read_authorizations`.

### En Ruby

```ruby
require 'net/http'
require 'json'

response = Net::HTTP.post_form(
  URI('https://datapass.api.gouv.fr/api/v1/oauth/token'),
  grant_type: 'client_credentials',
  client_id: ENV.fetch('DATAPASS_CLIENT_ID'),
  client_secret: ENV.fetch('DATAPASS_CLIENT_SECRET'),
  scope: 'read_authorizations'
)

body = JSON.parse(response.body)
access_token = body.fetch('access_token')
expires_at = Time.now + body.fetch('expires_in')
```

> `post_form` positionne automatiquement l'en-tête `Content-Type: application/x-www-form-urlencoded` attendu par l'endpoint OAuth2. Utiliser `Net::HTTP.post` avec une chaîne encodée manuellement échoue silencieusement (`invalid_request`) car le header n'est pas fixé.

### En Python

```python
import os
import requests

response = requests.post(
    'https://datapass.api.gouv.fr/api/v1/oauth/token',
    data={
        'grant_type': 'client_credentials',
        'client_id': os.environ['DATAPASS_CLIENT_ID'],
        'client_secret': os.environ['DATAPASS_CLIENT_SECRET'],
        'scope': 'read_authorizations',
    },
)

access_token = response.json()['access_token']
```

### En JavaScript (Node)

```javascript
const body = new URLSearchParams({
  grant_type: 'client_credentials',
  client_id: process.env.DATAPASS_CLIENT_ID,
  client_secret: process.env.DATAPASS_CLIENT_SECRET,
  scope: 'read_authorizations'
})

const response = await fetch('https://datapass.api.gouv.fr/api/v1/oauth/token', {
  method: 'POST',
  body
})

const { access_token: accessToken } = await response.json()
```

Les scopes disponibles sont détaillés dans [la documentation OpenAPI](/developpeurs/documentation) (section `securitySchemes.OAuth2`) :

| Scope | Usage |
| --- | --- |
| `public` | Informations minimales sur l'utilisateur (`GET /me`) ; n'autorise aucun accès aux demandes. |
| `read_authorizations` | Lecture des demandes, événements et habilitations. |
| `write_authorizations` | Création et mise à jour des demandes. |
| `read_webhooks` | Lecture de l'historique des appels webhooks (`GET /webhooks/{id}/attempts`). |

### Durée de vie du token

La réponse de `/oauth/token` contient `expires_in` (en secondes ; valeur par défaut : 7 200). Un dev naïf qui ré-authentifie à chaque requête sature inutilement l'endpoint. Mettre le token en cache jusqu'à `expires_at - marge` (par ex. 60 s avant expiration), puis redemander un token. Il n'y a pas de `refresh_token` avec le flow `client_credentials` : on redemande simplement un nouveau token avec les mêmes identifiants.

## Cas d'usage : tableau de bord de pilotage

Objectif : afficher en interne le nombre de demandes en cours, validées, refusées, avec une actualisation quotidienne.

L'endpoint `GET /demandes` accepte les filtres `state`, `siret`, pagine via `limit` + `offset`, et retourne les résultats triés par date de création décroissante (les plus récentes en premier). Voir [la documentation OpenAPI](/developpeurs/documentation) pour la liste complète des paramètres et du schéma `Demande`.

### Récupérer toutes les demandes validées d'un SIRET

```python
import os, requests

headers = {'Authorization': f'Bearer {access_token}'}
params = {'state[]': ['validated'], 'siret': '13002526500013', 'limit': 100}

demandes = []
offset = 0

while True:
    response = requests.get(
        'https://datapass.api.gouv.fr/api/v1/demandes',
        headers=headers,
        params={**params, 'offset': offset},
    )
    page = response.json()
    demandes.extend(page)

    if len(page) < params['limit']:
        break
    offset += params['limit']
```

### Construire des agrégats pour un dashboard

`limit` est plafonné à **1000** côté API. Au-delà, il faut paginer via `offset`.

```ruby
require 'net/http'
require 'json'

def fetch_page(offset:, limit: 1000, access_token:)
  uri = URI('https://datapass.api.gouv.fr/api/v1/demandes')
  uri.query = URI.encode_www_form(limit:, offset:)
  request = Net::HTTP::Get.new(uri)
  request['Authorization'] = "Bearer #{access_token}"

  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }
  JSON.parse(response.body)
end

demandes = []
offset = 0
limit = 1000

loop do
  page = fetch_page(offset:, limit:, access_token:)
  demandes.concat(page)
  break if page.size < limit

  offset += limit
end

par_etat = demandes.group_by { |d| d['state'] }.transform_values(&:count)
# => { "validated" => 42, "submitted" => 7, "draft" => 3 }
```

## Les endpoints utiles en lecture

| Endpoint | Usage |
| --- | --- |
| `GET /me` | Informations sur l'utilisateur lié au token (scope `public`) |
| `GET /definitions` | Types d'habilitation accessibles (avec la liste des clés `data` acceptées) |
| `GET /definitions/{id}` | Détail d'une définition (scopes, étapes sandbox/production) |
| `GET /demandes` | Liste des demandes (filtres `state`, `siret`) |
| `GET /demandes/{id}` | Détail d'une demande avec ses événements et habilitations |
| `GET /demandes/{id}/events` | Historique des événements d'une demande |
| `GET /habilitations` | Liste des habilitations actives |
| `GET /habilitations/{id}` | Détail d'une habilitation |

> **Bon à savoir** : l'API accepte aussi bien les identifiants avec préfixe (`D123`, `H456`) que sans (`123`, `456`).

## Comprendre la clé `data`

Chaque type d'habilitation possède un jeu d'attributs métier qui vivent sous la clé `data` d'une demande. La liste des clés acceptées pour un type donné est **dynamique** et exposée par `GET /definitions/{id}` sous le champ `data` :

```json
{
  "id": "api_entreprise",
  "data": ["intitule", "description", "destinataire_donnees_caractere_personnel", "duree_conservation_donnees_caractere_personnel", "cadre_juridique_url", "cadre_juridique_nature", "date_prevue_mise_en_production", "volumetrie_approximative", "scopes"]
}
```

**Avant toute intégration en écriture, récupérez dynamiquement ce tableau** pour construire votre payload : il peut évoluer (ajout d'un champ, dépréciation d'un scope). Voir le tutoriel [Exploiter l'API en écriture](/developpeurs/tutoriels/ecriture) pour l'usage complet.

## Lire les scopes d'une demande

Deux notions distinctes portent le mot « scope » dans l'API. Ne pas les confondre :

| Notion | Où | Format |
| --- | --- | --- |
| **Scope OAuth2** (`read_authorizations`, `write_authorizations`, `read_webhooks`, `public`) | Paramètre `scope` de `POST /oauth/token` | Chaîne unique ou liste séparée par des espaces (`'read_authorizations write_authorizations'`) |
| **Scope métier** (les périmètres de données demandés à un fournisseur) | Clé `data.scopes` d'une demande, et `scopes[]` d'une définition | Voir ci-dessous |

### Format dans la réponse `GET /demandes/{id}`

Sur une demande, `data.scopes` est **un tableau de chaînes**, contenant uniquement les `value` techniques cochées par le demandeur :

```json
{
  "id": 4242,
  "type": "api_entreprise",
  "state": "validated",
  "data": {
    "intitule": "Raccordement INSEE",
    "scopes": [
      "unites_legales_etablissements_insee",
      "associations_djepva"
    ]
  }
}
```

Aucun libellé, groupe, ni lien n'est inclus à ce niveau : c'est une liste plate de valeurs techniques.

### Résoudre libellé et groupe via `GET /definitions/{id}`

Pour afficher un libellé humain, un groupe ou un lien documentation, il faut joindre `data.scopes` avec `scopes[]` de la définition correspondante (clé pivot : `value`) :

```json
{
  "id": "api_entreprise",
  "scopes": [
    {
      "name": "Données unités légales et établissements - Insee",
      "value": "unites_legales_etablissements_insee",
      "group": "Informations générales",
      "link": "https://entreprise.api.gouv.fr/catalogue?...",
      "included": false,
      "disabled": false,
      "deprecated": false,
      "deprecated_date": null
    }
  ]
}
```

Détail des champs renvoyés pour chaque scope :

- **`value`** — identifiant technique, utilisé dans `data.scopes` d'une demande.
- **`name`** / **`group`** / **`link`** — libellé humain, regroupement métier et lien documentation pour l'affichage.
- **`included`** — quand `true`, scope toujours accordé par le fournisseur même absent de `data.scopes`. Pour la liste effective des scopes accordés à une habilitation validée, faites l'union de `data.scopes` et des `value` `included: true`.
- **`deprecated`** (+ **`deprecated_date`**) — scope conservé pour l'historique des anciennes demandes mais à exclure d'une UI de création.
- **`disabled`** — scope visible mais non cochable (par ex. réservé à certains profils d'usagers). Une demande validée peut tout de même en contenir.

> **Note** — une `value` présente dans `data.scopes` mais absente de la définition correspond à une suppression côté config : à conserver pour l'historique, à ne plus proposer à la modification.

```python
definition = requests.get(
    f'https://datapass.api.gouv.fr/api/v1/definitions/{demande["type"]}',
    headers={'Authorization': f'Bearer {access_token}'},
).json()

scopes_by_value = {s['value']: s for s in definition['scopes']}

for value in demande['data'].get('scopes', []):
    scope = scopes_by_value.get(value)
    if scope is None:
        continue
    print(f"[{scope['group']}] {scope['name']}")
```

Mettez la définition en cache (elle change rarement) plutôt que de la re-télécharger pour chaque demande.

## Aller plus loin

- [Documentation OpenAPI complète](/developpeurs/documentation)
- [Tutoriel : exploiter l'API en écriture](/developpeurs/tutoriels/ecriture)
- [Tutoriel : suivre les demandes via webhooks](/developpeurs/tutoriels/webhooks)
- [Cycle de vie d'une demande](https://github.com/etalab/data_pass/blob/main/docs/lifecycle_documentation.md)
