# API Datapass

Vous trouverez la documentation technique de notre APIi OAuth 2 dans le fichier config/openapi/v1.yml, accessible en local depuis /developpeurs.

L'accès à l'API requiert un compte avec des droits spécifiques. Vous pouvez demander un accès à l'API en contactant notre équipe de support.

## Accéder à l'API en local

### Setup mode facile

Les seeds ajoutent le role `api_entreprise:developer` et créent une application (identifiants: client_id/so_secret) à l'utilisteur `api-entreprise@yopmail.com`

### Setup mode avancé

Votre utilisateur doit avoir le rôle "developer" (par exemple `api_entreprise:developer`) pour accéder, via l'API, aux demandes et habilitations API Entreprise.

Cet utilisateur doit avoir une application OAuth, vous pouvez la créer avec le code suivant :

```ruby
user = User.find(xxx)

Doorkeeper::Application.create!(
  name: 'Accès API Entreprise',
  uid: 'client_id',
  secret: 'so_secret',
  owner: user,
)
```

### Récupérer un jeton

Vous devez ensuite demander un jeton, via une commande curl par exemple :

```bash
CLIENT_ID="client_id"
CLIENT_SECRET="so_secret"
TOKEN_URL="http://localhost:3000/api/oauth/token"

ACCESS_TOKEN=$(curl -s -X POST "$TOKEN_URL" \
  -d "grant_type=client_credentials" \
  -d "client_id=$CLIENT_ID" \
  -d "client_secret=$CLIENT_SECRET" \
  | jq -r .access_token)
```

### Requêter l'API

Vous pouvez maintenant utiliser l'API en précisant le jeton d'accès dans l'en-tête de la requête :

```bash
curl -H "Authorization: Bearer $ACCESS_TOKEN" "http://localhost:3000/api/v1/me"
```
