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
- `403 Forbidden` — vous n'avez pas le rôle développeur pour ce type, le scope `write_authorizations` manque (titre « Droit API manquant » dans ce cas, voir [Droits de soumission et de validation](#droits-de-soumission-et-de-validation)), ou le compte propriétaire du jeton a été banni de DataPass (erreur « Compte banni »). Un jeton émis avant le bannissement cesse alors aussi de fonctionner, sur tous les endpoints de l’API.
- `422 Unprocessable Content` — le payload ne respecte pas la définition, ou les données ne passent pas les validations d’une demande en brouillon (erreur « Demande invalide »). Un payload accepté auparavant peut désormais être rejeté.

Une demande créée par l’API est un brouillon : seules les validations d’un brouillon s’appliquent, comme sur le formulaire web, ce qui permet de la créer incomplète. Les données sont validées en totalité lorsque le demandeur soumet la demande depuis DataPass.

La création applique aussi les règles d’accès du formulaire web. Elle est refusée en `422` dans les cas suivants :

- le formulaire n’est pas ouvert aux demandeurs (par exemple une étape de production, qui ne se démarre qu’à partir de la demande de bac à sable) : erreur « Formulaire non disponible » ;
- l’organisation est fermée selon l’INSEE : erreur « Organisation fermée » ;
- le type d’habilitation est unique par organisation et une demande est déjà en cours ou validée : erreur « Demande déjà existante » ;
- le demandeur a été exclu de DataPass : erreur « Demandeur invalide », sans plus de précision.

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

`PATCH /demandes/{id}` permet de mettre à jour une demande **en état `draft` ou `changes_requested`** depuis l'API, comme le demandeur sur le formulaire web. Dès qu’une demande est soumise (`submitted`) ou traitée, elle n’est plus modifiable via cet endpoint : l’API répond `422` avec l’erreur « État non modifiable ».

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

## Cas d'usage : soumission et validation par un fournisseur de données

Un fournisseur de données (FD) qui a recueilli lui-même le consentement du demandeur peut créer, soumettre puis valider une demande sans renvoyer le demandeur sur DataPass. Ces deux actions sont des **droits distincts**, accordés par un administrateur DataPass à votre application, FD par FD, après qualification de votre parcours.

| Action | Endpoint | Scope du jeton |
| --- | --- | --- |
| Soumettre | `POST /demandes/{id}/soumettre` | `submit_authorizations` |
| Valider | `POST /demandes/{id}/valider` | `validate_authorizations` |

Ces scopes ne se demandent pas librement : une fois le droit accordé, demandez un **nouveau jeton** avec le scope correspondant. Sans droit actif, ou avec un jeton antérieur à l'octroi, la réponse est `403` (titre « Droit API manquant »).

### Soumettre

```ruby
uri = URI("https://datapass.api.gouv.fr/api/v1/demandes/#{demande_id}/soumettre")
request = Net::HTTP::Post.new(uri)
request['Authorization'] = "Bearer #{access_token}"
request['Content-Type'] = 'application/json'
request.body = {
  consentement: {
    terms_of_service_accepted: true,
    data_protection_officer_informed: true
  }
}.to_json
```

- Le demandeur reste la personne indiquée à la création : l'API ne soumet jamais au nom du FD.
- Vous déclarez avoir recueilli le consentement du demandeur en transmettant dans `consentement` chaque case que le demandeur doit cocher dans l'interface (CGU, information du DPO, cases propres à certains types…), à `true`. La liste des cases exigées pour un type est dans `consentements` de `GET /definitions/{id}`. Une case exigée absente ou à `false` empêche la soumission, avec une erreur par case (`source.pointer` : `/consentement/<case>`).
- Si vous avez vous-même vérifié les emails de contact de la demande, transmettez `"verified_email": true` : DataPass n'effectue alors pas sa propre vérification de joignabilité (le format reste contrôlé).
- La demande est contrôlée comme dans l'interface. Si elle est incomplète, elle reste en `draft` et la réponse `422` contient **une erreur par champ**, avec `source.pointer` (ex. `/data/delegue_protection_donnees_family_name`).
- Seules les demandes `draft` ou `changes_requested` sont soumettables. Les autres renvoient une erreur « État non modifiable ».
- Après la soumission, la demande est `submitted`, avec les mêmes effets qu'une soumission classique (webhook `submit`). L'historique indique qu'elle a été soumise par API, avec le nom de votre application.

### Valider

```ruby
request.body = {
  instructeur: { email: 'instructeur@example.com' },
  message: 'Demande conforme au cadre juridique.'
}.to_json
```

- `instructeur.email` désigne un compte DataPass existant qui a le rôle d'instructeur sur ce type. Une personne nommément identifiée doit porter la responsabilité de la décision.
- Seules les demandes `submitted` sont validables par API. Le refus, la demande de modification et la révocation restent dans l'interface DataPass.
- La validation a les mêmes effets qu'une validation dans l'interface (habilitation créée, anciennes habilitations `obsolete`, passerelles, webhook `approve`). La réponse contient la demande avec l'habilitation active dans `habilitations`.

### Métadonnées

À la création et à la mise à jour, `demande.metadata` accepte un objet libre (ex. `{ "campagne": "migration-editeur-x", "source": "api" }`). Il est restitué dans les réponses de l'API et dans la charge utile de chaque webhook de la demande, ce qui permet de reconnaître vos demandes et de ne pas rejouer vos propres traitements. Il n'est visible que des applications du FD et des administrateurs DataPass, et ne doit contenir aucune donnée personnelle.

### Désactiver les emails DataPass

Les appels de création, de soumission et de validation acceptent `"notifications": false` à la racine du corps. Le paramètre n'est appliqué que si le contrat de votre FD le permet ; sinon, l'appel aboutit, les emails partent, et la réponse contient `meta.warnings`. Les webhooks sont toujours envoyés ; leur charge utile reprend la valeur effectivement appliquée dans le champ `notifications`.

## Droits de soumission et de validation

En plus de `write_authorizations` (création et mise à jour, inchangé), deux scopes optionnels distinguent la **soumission** et la **validation** de demandes par l’API :

| Scope | Droit |
| --- | --- |
| `submit_authorizations` | Soumettre des demandes pour les fournisseurs de données autorisés |
| `validate_authorizations` | Valider des demandes pour les fournisseurs de données autorisés |

### Comment obtenir un droit

- Ces droits ne se demandent pas depuis « Mes clefs d’accès API » : à la création d’une clef, vous n’obtenez que `public`, `read_authorizations` et `read_webhooks`.
- Un administrateur DataPass les accorde à votre application, **fournisseur de données par fournisseur de données**, après qualification du parcours du fournisseur. Contactez-nous pour en faire la demande.
- Les types d’habilitation sur lesquels votre application peut agir restent limités par les rôles « développeur » de son propriétaire.
- Un droit accordé n’apparaît pas dans les jetons déjà émis : demandez un **nouveau jeton** en incluant le scope voulu. Les jetons `client_credentials` durent 2 heures.

### Réponses `403`

Dans tous les cas, l’erreur suit le format `errors[]` habituel avec le titre « Droit API manquant ».

- le jeton ne porte pas le scope exigé : « Le jeton d’accès ne permet pas cette action. Si un droit vient d’être accordé à votre application, demandez un nouveau jeton d’accès. » Ce cas s’applique désormais à **tous** les endpoints qui exigent un scope (il renvoyait auparavant une erreur `422`) ;
- le jeton porte le scope mais l’application n’a pas de droit actif pour le fournisseur de données du type d’habilitation : « Votre application n’est pas autorisée à soumettre des demandes pour ce fournisseur de données. » (ou « valider » pour la validation).

```json
{
  "errors": [
    {
      "status": "403",
      "title": "Droit API manquant",
      "detail": "Votre application n’est pas autorisée à soumettre des demandes pour ce fournisseur de données."
    }
  ]
}
```

### Révocation

Un administrateur peut révoquer un droit à tout moment. La révocation est effective **immédiatement**, même avec un jeton qui porte encore le scope : le droit est revérifié à chaque appel. La suppression d’une application révoque automatiquement ses droits.

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

## Rattachement du demandeur à son organisation

Lorsque `POST /demandes` crée le demandeur, il est rattaché à l'organisation (identifiée par `organisation.siret`) par un lien **non vérifié** : DataPass n'a, à ce stade, aucune preuve que cette personne appartient à cette organisation.

- **Vérification** : le lien ne devient vérifié qu'à la première connexion ProConnect du demandeur, et seulement si le fournisseur d'identité utilisé garantit le SIRET (`siret_verified`). Avec un fournisseur d'identité qui ne le garantit pas, le lien reste non vérifié, selon les règles habituelles de DataPass.
- **Effet pour le demandeur** : tant que le lien n'est pas vérifié, le demandeur retrouve sur son tableau de bord les demandes dont il est lui-même le demandeur, y compris celle créée par votre appel. En revanche, il ne voit pas les autres demandes et habilitations de l'organisation (filtre « Organisation » indisponible), et un bandeau d'information lui indique : « Nous n’avons pas pu vérifier votre lien avec l’organisation que vous avez sélectionnée, vous ne pourrez pas consulter l’ensemble des demandes et habilitations de l’organisation. »
- **Continuité du compte** : après sa première connexion ProConnect, la demande reste rattachée au même compte, retrouvé grâce à l'email. Un identifiant ProConnect (`sub`) déjà associé à un compte ayant un autre email est refusé à la connexion.

## Workflow recommandé

1. **Créer** la demande en `draft` depuis votre formulaire/CRM (`POST /demandes`).
2. **Rediriger** l'utilisateur vers `https://datapass.api.gouv.fr/demandes/{id}` pour qu'il finalise et soumette.
3. **Suivre** les transitions d'état (soumission, validation, refus) via les webhooks — voir [le tutoriel webhooks](/developpeurs/tutoriels/webhooks).
4. **Synchroniser** l'habilitation délivrée dans votre système interne à réception de l'événement `approve`.

## Aller plus loin

- [Documentation OpenAPI — POST /demandes](/developpeurs/documentation)
- [Tutoriel : suivre les demandes via webhooks](/developpeurs/tutoriels/webhooks)
- [Cycle de vie d'une demande](https://github.com/etalab/data_pass/blob/main/docs/lifecycle_documentation.md)
