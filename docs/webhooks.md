## Implémentation d'un webhook

DataPass possède un système de webhooks permettant de souscrire aux différents
événements liés à une habilitation. Par défaut ce système est désactivé (en faveur
d'emails de notifications et d'un appel via un bridge (code spécifique au
fournisseur de service) lors d'une validation d'une habilitation).

Si vous voulez avoir un contrôle plus fin du cycle de vie des habilitations, vous
pouvez utiliser ce système (par exemple pour gérer un CRM, mettre en place des
statistiques..).

Le système de webhooks utilise l'approche du token de vérification et du header
`X-Hub-Signature-256` permettant d'authentifier les appels depuis le endpoint cible.

L'implémentation des webhooks s'effectue en 2 étapes: une partie sur DataPass et
une partie sur votre système.

### Partie 1: DataPass

Afin de pouvoir activer les webhooks sur DataPass, il faut définir 2 variables
d'environnement:

1. Une jeton de vérification qui permettra de signer les appels ;
2. L'URL de l'endpoint qui acceptera les appels webhooks.

Avec le service identifié dans DataPass comme `super_service`, les variables
seront:

1. `SUPER_SERVICE_VERIFY_TOKEN`
1. `SUPER_SERVICE_WEBHOOK_URL`

Par exemple pour API Entreprise, identifié comme `api_entreprise`, les variables
sont:

1. `API_ENTREPRISE_VERIFY_TOKEN`
1. `API_ENTREPRISE_WEBHOOK_URL`

Dès que ces 2 variables sont définies, l'activation du système de webhook
s'effectue en créant un notifier spécifique au système portant le nom de
`SuperServiceNotifier`. Les notifiers permettent de notifier des entités
tierces, telles que les demandeurs, contacts RGPD etc etc.. et propose des
méthodes outils pour manipuler des emails et des webhooks.

Ce nouveau notifier doit hériter soit de:

* [`ApplicationNotifier`](../app/notifiers/application_notifier.rb) si vous
    voulez controller l'ensemble des messages envoyés ;
* [`BaseNotifier`](../app/notifiers/base_notifier.rb) si vous voulez garder
    certains comportements de base des notifications

Chacune des méthodes correspond à un événement associé à l’habilitation,
défini dans le modèle `AuthorizationRequest` (la description de chacun de ces événements
se trouve plus bas dans ce document)

Il est possible de mixer, en fonction de l'événement, l'envoi d'email ou de
webhooks. Un exemple d'implémentation qui utilise des webhooks et des emails
est disponible ici:
[`APIEntreculierNotifier`](../app/notifiers/api_entreculier_notifier.rb) (qui
s'occupe d'API Entreprise et API Particulier)

### Partie 2: Système recevant les webhooks

Le système de webhook effectue des requêtes HTTP de type POST, avec comme `body`
un json qui est sous le format ci-dessous :

```json
{
  "event": "refuse",
  "fired_at": 1628253953,
  "model_type": "authorization_request/api_entreprise",
  "data": model_data
}
```

Avec:

- `event`, `string`: l'événement associé au changement d'état de l’habilitation.
  Les valeurs possibles sont:
  - `create`: la demande d’habilitation vient d'être créée ;
  - `update`: la demande d’habilitation a été mise à jour par le demandeur ;
  - `submit`: la demande d’habilitation a été envoyée par le demandeur ;
  - `refuse`: la demande d’habilitation a été refusée par un instructeur ;
  - `revoke`: l’habilitation a été révoquée par un instructeur ;
  - `request_changes`: la demande d’habilitation a été instruite par un instructeur et
    demande des modifications de la part du demandeur ;
  - `archive`: la demande d’habilitation a été archivé par un instructeur ;
  - `approve`: la demande d’habilitation a été validée par un instructeur ;
  - `reopen`: l'habilitation a été réouverte par le demandeur ;
  - `cancel_reopening`: la demande de réouverture a été annulée par un demandeur
      ou un instructeur ;
  - `transfer`: la demande d'habilitation a été transférée à un nouveau
      demandeur ou nouvelle organisation
- `fired_at`, `timestamp`: timestamp correspondant au moment où le webhook a été
  déclenché ;
- `model_type`, `string`: correspond au modèle de donnée. Il s'agit de la nom de
    du model sous format " underscore ". Par exemple pour
    `AuthorizationRequest::APIParticulier` il s'agit de `authorization_request/api_particulier`
- `data`, `json`: données de la demande d’habilitation. Le serializaer utilisé est [`WebhookAuthorizationRequestSerializer`](../app/serializers/webhook_authorization_request_serializer.rb)

Un exemple de payload pour `model_data`:

```json
{
  // ID technique de la demande’habilitation
  "id": 9001,
  // ID Public de la demande
  "public_id": "a90939e8-f906-4343-8996-5955257f161d",
  // Status de la demande d’habilitation. Les valeurs peuvent être:
  // * draft : en attente d'envoi
  // * submitted : demande d’habilitation envoyée
  // * changes_requested : la demande d’habilitation a été revue par un instructeur et demande des modifications
  // * validated : habilitation validée
  // * refused : habilitation refusée
  // * revoked : habilitation révoquée
  // * archived : habilitation archivée
  // * deleted : habilitation suprimée

  "state": "approve"
  // ID du formulaire associé à la demande. Cette liste se trouve dans config/authorization_request_forms/
  "form_uid": "api-entreprise-demande-libre",
  // Payload de l'organisation
  "organization": {
    "id": 9002,
    "raison_sociale": "UMAD CORP",
    "siret": "98043033400022"
  },
  // Payload du demandeur
  "applicant": {
    "id": 9003,
    "email": "jean.dupont@beta.gouv.fr",
    "given_name": "Jean",
    "family_name": "Dupont",
    "phone_number": "0836656565",
    "job_title": "Rockstar"
  },
  // Les données associée au type de l'habilitation. En fonction du type les clés varient. Un exemple est donnée ci-dessous avec des clés possibles
  "data": {
    "intitule": "Ma demande",
    "scopes": [
      "cnaf_identite",
      "cnaf_enfants"
    ]
    "contact_technique_given_name": "Tech",
    "contact_technique_family_name": "Os",
    "contact_technique_phone_number": "08366666666",
    "contact_technique_job_title": "DSI",
    "contact_technique_email": "tech@beta.gouv.fr"
  }
}
```

La requête HTTP possède comme `Application-Type` la valeur
`application/json`

Votre serveur doit obligatoirement répondre avec un status de succès. Les codes
HTTP considérés comme étant un succès sont `200`, `201` et `204`. Le cas
contraire, DataPass continuera d'essayer d'envoyer le webhook jusqu'à obtenir
un code de succes. Les temps d'attentes sont exponentiels entre chaque
tentatives. Ci-dessous un tableau avec des valeurs plausibles:

<details>
<summary>Tableau des essais (cliquez pour ouvrir).</summary>
<pre>
 # | Prochain essai     | Temps d'attente total
 -------------------------------------------
 1 |       0d 0h 0m 20s |       0d 0h 0m 20s
 2 |       0d 0h 0m 26s |       0d 0h 0m 46s
 3 |       0d 0h 0m 46s |       0d 0h 1m 32s
 4 |       0d 0h 1m 56s |       0d 0h 3m 28s
 5 |       0d 0h 4m 56s |       0d 0h 8m 24s
 6 |      0d 0h 11m 10s |      0d 0h 19m 34s
 7 |      0d 0h 22m 26s |       0d 0h 42m 0s
 8 |      0d 0h 40m 56s |      0d 1h 22m 56s
 9 |       0d 1h 9m 16s |      0d 2h 32m 12s
10 |      0d 1h 50m 26s |      0d 4h 22m 38s
11 |      0d 2h 47m 50s |      0d 7h 10m 28s
12 |       0d 4h 5m 16s |     0d 11h 15m 44s
13 |      0d 5h 46m 56s |      0d 17h 2m 40s
14 |      0d 7h 57m 26s |        1d 1h 0m 6s
15 |     0d 10h 41m 46s |     1d 11h 41m 52s
16 |      0d 14h 5m 20s |      2d 1h 47m 12s
17 |     0d 18h 13m 56s |       2d 20h 1m 8s
18 |     0d 23h 13m 46s |     3d 19h 14m 54s
19 |      1d 5h 11m 26s |      5d 0h 26m 20s
20 |     1d 12h 13m 56s |     6d 12h 40m 16s
21 |     1d 20h 28m 40s |       8d 9h 8m 56s
22 |       2d 6h 3m 26s |    10d 15h 12m 22s
23 |      2d 17h 6m 26s |     13d 8h 18m 48s
24 |      3d 5h 46m 16s |      16d 14h 5m 4s
25 |     3d 20h 11m 56s |     20d 10h 17m 0s
</pre>
</details>

Si au bout de 5 essais le serveur distant n'a toujours pas répondu positivement,
un email d'erreur est envoyé aux instructeurs du type d'habilitation avec
l'erreur exacte du serveur distant.

Niveau sécurité, afin de garantir que la payload envoyée est bien émise par
DataPass, 2 headers sont ajoutés à la requête :

- `X-Hub-Signature-256`, `string` : [HMAC en SHA256 ( Hash-based Message Authentication Code
  )](https://fr.wikipedia.org/wiki/HMAC) ayant pour clé la valeur de jeton de
  vérification et comme données le contenu du body de la requête.

Ce header permet d'authentifier chaque payload reçu par votre
système : en effet, vu que le token de vérification est seulement connu de
DataPass et de votre système, il est impossible pour un attaquant de forger une
requête et de taper sur votre système sans connaître la valeur du token de
vérification.

⚠️ Il est **impératif de vérifier la valeur `X-Hub-Signature-256` dans votre système**, le cas contraire n'importe
quel personne connaissant l'url de votre service pourra exploiter cette faille
et donc générer des accès à vos données.

Ci dessous un exemple (en ruby/rails) qui vérifie la valeur du `X-Hub-Signature-256`:

```ruby
hub_signature = request.headers['X-Hub-Signature-256']
payload_body = request.body
verify_token = ENV['DATAPASS_WEBHOOK_VERIFY_TOKEN']

compute_hub_signature = 'sha256=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), verify_token, payload_body)

# La valeur ci-dessous est true si la signature est valide
Rack::Utils.secure_compare(hub_signature, compute_hub_signature)
```

Lors de l'événement `validate`, si votre système répond avec un ID de jeton
celui-ci sera affecté à l’habilitation.

Le format attendu est au format json:

```json
{
  "token_id": "1234567890asdfghjkl"
}
```
