# Tracer une modification admin (`admin_change`)

Quand un admin ou un tech effectue une modification sur les données d'une demande
ou d'une habilitation (correction en console, migration de données, demande de
support), il doit créer un évènement `admin_change` pour tracer le changement
dans l'historique visible des utilisateurs.

## Utilisation en console

### Modifier des données formulaire (diff automatique)

```ruby
Admin::CreateAdminChange.call(
  user: User.find_by(email: 'admin@example.com'),
  authorization_request: AuthorizationRequest.find(42),
  public_reason: "Correction de l'adresse du responsable technique",
  private_reason: "Ticket support #SP-1234",
) do |ar|
  ar.update!(data: ar.data.merge('contact_technique_email' => 'nouveau@email.com'))
end
```

Le service :
1. Prend un snapshot du champ `data` de la demande
2. Exécute le bloc
3. Compare avant/après pour calculer le diff automatiquement
4. Crée l'`AdminChange` et l'`AuthorizationRequestEvent`

Le diff apparaît dans l'historique sous forme de liste de changements.

### Modifier une habilitation

```ruby
Admin::CreateAdminChange.call(
  user: User.find_by(email: 'admin@example.com'),
  authorization_request: AuthorizationRequest.find(42),
  public_reason: "Correction des données de l'habilitation",
  private_reason: "Ticket support #SP-5678",
) do |ar|
  ar.authorizations.last.update!(data: ar.authorizations.last.data.merge('champ' => 'valeur'))
end
```

Le diff ne capture que les changements sur le `data` de l'`AuthorizationRequest`.
Les modifications sur l'`Authorization` ou sur des champs hors `data` produisent
un diff vide — la `public_reason` explique ce qui s'est passé.

### Changement technique sans bloc

```ruby
Admin::CreateAdminChange.call(
  user: User.find_by(email: 'admin@example.com'),
  authorization_request: AuthorizationRequest.find(42),
  public_reason: "Migration des données suite à mise en production",
  private_reason: "Déploiement v2.3",
)
```

Sans bloc, le diff est vide. Seule la raison publique apparaît dans l'historique.

## Paramètres

| Paramètre | Obligatoire | Description |
|-----------|-------------|-------------|
| `user` | oui | L'admin qui effectue le changement |
| `authorization_request` | oui | La demande concernée |
| `public_reason` | oui | Raison affichée dans l'historique (visible par tous) |
| `private_reason` | non | Raison interne (ex: référence ticket support), visible uniquement par les admins |
| bloc | non | Bloc recevant l'`authorization_request`, exécuté pour appliquer les modifications |

## Affichage

L'évènement apparaît dans l'historique de la demande avec :
- Le nom de l'admin qui a effectué la modification
- La raison publique
- La liste des changements (si le diff est non vide)

La raison privée est affichée dans l'interface d'historique uniquement pour les utilisateurs admin.
