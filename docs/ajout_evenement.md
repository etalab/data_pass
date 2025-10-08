# Ajout d'un nouvel événement

## Définition

Un événement (`AuthorizationRequestEvent`) est un enregistrement historique qui
permet de tracer toutes les actions effectuées sur une demande d'habilitation.
Chaque événement est associé à une entité spécifique (par exemple une autorisation,
un message, une révocation, etc.) et peut contenir des métadonnées supplémentaires.

## Checklist globale

Pour ajouter un nouvel événement au système, il faut suivre ces étapes :

1. Ajouter le nom de l'événement dans le modèle `AuthorizationRequestEvent`
2. Configurer la validation de l'entité associée
3. Mettre à jour le décorateur pour l'affichage de l'événement
4. Ajouter l'événement dans la requête de récupération des événements
5. Créer une migration pour mettre à jour la contrainte de base de données
6. Ajouter les traductions dans les fichiers I18n
7. Créer un trait de factory pour les tests
8. Mettre à jour les tests existants si nécessaire

## 1. Modèle `AuthorizationRequestEvent`

Le modèle `AuthorizationRequestEvent` contient une constante `NAMES` qui liste
tous les événements possibles.

### Fichier: `app/models/authorization_request_event.rb`

#### Ajouter le nom de l'événement

Ajouter le nom du nouvel événement dans la constante `NAMES` :

```ruby
NAMES = %w[
  submit
  approve
  refuse
  request_changes
  revoke
  reopen
  transfer
  cancel_reopening
  cancel_reopening_from_instructor

  applicant_message
  instructor_message

  admin_update
  bulk_update  # Nouvel événement ajouté

  system_reminder
  system_archive
].freeze
```

#### Ajouter la validation de l'entité

Dans la méthode `entity_type_validation`, ajouter la validation pour lier l'événement à son type d'entité :

```ruby
def entity_type_validation
  return if %w[approve reopen].include?(name) && entity_type == 'Authorization'
  return if %w[applicant_message instructor_message].include?(name) && entity_type == 'Message'
  return if %w[approve refuse request_changes revoke].exclude?(name) && entity_type == 'AuthorizationRequest'
  return if %w[bulk_update].include?(name) && entity_type == 'BulkAuthorizationRequestUpdate'  # Nouvelle validation

  errors.add(:entity_type, :invalid)
end
```

## 2. Décorateur `AuthorizationRequestEventDecorator`

Le décorateur gère l'affichage de chaque événement dans l'interface utilisateur.

### Fichier: `app/decorators/authorization_request_event_decorator.rb`

Mettre à jour la méthode `text` pour définir comment afficher l'événement :

```ruby
def text
  case name
  when 'refuse', 'request_changes', 'revoke', 'cancel_reopening_from_instructor', 'bulk_update'
    h.simple_format(entity.reason)
  when 'applicant_message', 'instructor_message'
    h.simple_format(entity.body)
  # ...
  end
end
```

Dans cet exemple, l'événement `bulk_update` affiche la propriété `reason` de l'entité associée.

## 3. Requête `AuthorizationRequestEventsQuery`

Cette classe récupère tous les événements liés à une demande d'habilitation.

### Fichier: `app/queries/authorization_request_events_query.rb`

#### Ajouter les IDs dans `entity_ids`

```ruby
def entity_ids
  [
    authorization_request.id,
    authorization_request.changelogs.pluck(:id),
    authorization_request.messages.pluck(:id),
    authorization_request.authorization_ids,
    authorization_request.denial_of_authorization_ids,
    authorization_request.instructor_modification_request_ids,
    authorization_request.revocation_ids,
    authorization_request.transfer_ids,
    authorization_request.reopening_cancellation_ids,
    authorization_request.bulk_updates.pluck(:id),  # Nouvelle ligne
  ]
end
```

#### Mettre à jour la condition SQL dans `sql_condition_template`

```ruby
def sql_condition_template
  "(entity_id in (?) and entity_type = 'AuthorizationRequest') or" \
  "(entity_id in (?) and entity_type = 'AuthorizationRequestChangelog') or" \
  "(entity_id in (?) and entity_type = 'Message') or" \
  "(entity_id in (?) and entity_type = 'Authorization') or" \
  "(entity_id in (?) and entity_type = 'DenialOfAuthorization') or" \
  "(entity_id in (?) and entity_type = 'InstructorModificationRequest') or" \
  "(entity_id in (?) and entity_type = 'RevocationOfAuthorization') or" \
  "(entity_id in (?) and entity_type = 'AuthorizationRequestTransfer') or" \
  "(entity_id in (?) and entity_type = 'AuthorizationRequestReopeningCancellation') or" \
  "(entity_id in (?) and entity_type = 'BulkAuthorizationRequestUpdate')"  # Nouvelle condition
end
```

## 4. Migration de base de données

Une contrainte de base de données garantit la cohérence entre le nom de l'événement et le type d'entité associé.

### Créer une nouvelle migration

```sh
bin/rails generate migration add_bulk_update_constraint_to_authorization_request_events
```

### Exemple de migration

```ruby
class AddBulkUpdateConstraintToAuthorizationRequestEvents < ActiveRecord::Migration[7.2]
  def up
    execute <<-SQL
      ALTER TABLE authorization_request_events
      DROP CONSTRAINT entity_type_validation
    SQL

    execute <<-SQL
      ALTER TABLE authorization_request_events
      ADD CONSTRAINT entity_type_validation
      CHECK (
        (name = 'refuse' AND entity_type = 'DenialOfAuthorization') OR
        (name = 'request_changes' AND entity_type = 'InstructorModificationRequest') OR
        (name = 'approve' AND entity_type = 'Authorization') OR
        (name = 'reopen' AND entity_type = 'Authorization') OR
        (name = 'submit' AND entity_type = 'AuthorizationRequestChangelog') OR
        (name = 'admin_update' AND entity_type = 'AuthorizationRequestChangelog') OR
        (name = 'applicant_message' AND entity_type = 'Message') OR
        (name = 'instructor_message' AND entity_type = 'Message') OR
        (name = 'revoke' AND entity_type = 'RevocationOfAuthorization') OR
        (name = 'transfer' AND entity_type = 'AuthorizationRequestTransfer') OR
        (name = 'cancel_reopening' AND entity_type = 'AuthorizationRequestReopeningCancellation') OR
        (name = 'bulk_update' AND entity_type = 'BulkAuthorizationRequestUpdate') OR
        (entity_type = 'AuthorizationRequest')
      )
    SQL
  end

  def down
    # Revenir à l'état précédent sans la nouvelle contrainte
    execute <<-SQL
      ALTER TABLE authorization_request_events
      DROP CONSTRAINT entity_type_validation
    SQL

    execute <<-SQL
      ALTER TABLE authorization_request_events
      ADD CONSTRAINT entity_type_validation
      CHECK (
        # ... contrainte sans bulk_update
      )
    SQL
  end
end
```

## 5. Traductions I18n

Les traductions permettent d'afficher les événements dans l'interface utilisateur.

### Fichier: `config/locales/fr.yml`

Ajouter la traduction sous la clé `authorization_request_event_decorator` :

```yaml
fr:
  authorization_request_event_decorator:
    text:
      bulk_update:
        text: |
          Une mise à jour globale sur ce type d'habilitation a été effectuée :

          <br />

          <blockquote>
            %{text}
          </blockquote>
```

La variable `%{text}` sera remplacée par le contenu de l'événement (généralement `entity.reason` ou `entity.body`).

## 6. Factory pour les tests

Les factories permettent de créer facilement des événements dans les tests.

### Fichier: `spec/factories/authorization_request_events.rb`

Ajouter un trait pour le nouvel événement :

```ruby
FactoryBot.define do
  factory :authorization_request_event do
    # ... autres traits

    trait :bulk_update do
      name { 'bulk_update' }

      user

      entity factory: %i[bulk_authorization_request_update]

      after(:build) do |authorization_request_event, evaluator|
        authorization_request_event.entity = build(:bulk_authorization_request_update, authorization_definition_uid: evaluator.authorization_request.definition.id) if evaluator.authorization_request.present?
      end
    end
  end
end
```

### Utilisation dans les tests

```ruby
# Créer un événement bulk_update
event = create(:authorization_request_event, :bulk_update, authorization_request: ma_demande)

# Créer avec une demande d'habilitation spécifique
event = create(:authorization_request_event, :bulk_update, authorization_request: authorization_request)
```

## 7. Mise à jour des tests

Selon le type d'événement, il peut être nécessaire d'adapter les tests existants.

### Exemple : exclure l'événement de certains tests

Si l'événement ne suit pas exactement le même pattern que les autres (par exemple, il ne retourne pas directement une `AuthorizationRequest`), il faut l'exclure des tests génériques :

```ruby
RSpec.describe AuthorizationRequestEvent do
  describe '#authorization_request' do
    it 'works for each event (except bulk_update)' do
      AuthorizationRequestEvent::NAMES.each do |name|
        next if name == 'bulk_update'  # Exclure l'événement

        expect(build(:authorization_request_event, name).authorization_request).to be_a(AuthorizationRequest)
      end
    end
  end
end
```

### Exemple : ajuster les tests d'intégration

Certains tests peuvent nécessiter des ajustements de date pour éviter les conflits avec les nouveaux événements :

```ruby
let(:authorization_request) { create(:authorization_request, :api_entreprise, created_at: 1.month.ago) }
```

## Exemple complet : événement `bulk_update`

L'événement `bulk_update` a été ajouté dans le commit `9ea2eb25a38e090279aa5f71b475ecfb16cc1d13`. Voici un résumé des fichiers modifiés :

### Fichiers modifiés

1. `app/models/authorization_request_event.rb` - Ajout du nom et validation
2. `app/decorators/authorization_request_event_decorator.rb` - Affichage
3. `app/queries/authorization_request_events_query.rb` - Récupération des événements
4. `db/migrate/...` - Migration pour la contrainte DB
5. `config/locales/fr.yml` - Traductions
6. `spec/factories/authorization_request_events.rb` - Factory
7. `spec/models/authorization_request_event_spec.rb` - Exclusion du test générique
8. `spec/features/instruction/events_spec.rb` - Ajustement de date
9. `spec/queries/authorization_request_events_query_spec.rb` - Ajustement de date

### Caractéristiques de l'événement

- **Nom**: `bulk_update`
- **Entité associée**: `BulkAuthorizationRequestUpdate`
- **Affichage**: Affiche `entity.reason` dans une blockquote
- **Utilisateur**: Requis (événement créé par un utilisateur, pas un événement système)

## Points d'attention

- **Nommer l'événement de manière descriptive** : Le nom doit être clair et suivre la convention snake_case
- **Créer le modèle d'entité associé** : Si l'événement nécessite une nouvelle entité (comme `BulkAuthorizationRequestUpdate`), il faut créer le modèle, sa factory et ses tests
- **Vérifier les associations** : S'assurer que l'association entre `AuthorizationRequest` et la nouvelle entité est bien définie
- **Tester l'affichage** : Vérifier que l'événement s'affiche correctement dans l'interface d'instruction
- **Événements système** : Si l'événement commence par `system_`, il ne nécessite pas d'utilisateur (voir contrainte `user_id_not_null_unless_system_event`)

