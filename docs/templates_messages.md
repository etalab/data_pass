# Templates de messages pour l'instruction

## Vue d'ensemble

Cette fonctionnalité permet aux instructeurs de gagner du temps lors de la modération des demandes d'habilitation en créant des templates de messages réutilisables pour les demandes de modifications et les refus.

Les templates permettent de standardiser les réponses tout en gardant la possibilité d'interpoler des informations dynamiques spécifiques à chaque demande (URL de la demande, intitulé, identifiant).

## Rôles et permissions

### Manager

Le **manager** est un nouveau rôle spécifique à un type d'habilitation. C'est le seul rôle qui peut :
- Créer des nouveaux templates
- Modifier des templates existants
- Supprimer des templates
- Prévisualiser des templates

Un manager est également un instructeur et un reporter (transitivité des rôles).

### Instructeur

Les instructeurs peuvent :
- Consulter la liste des templates disponibles
- Utiliser les templates lors de demandes de modifications ou de refus
- Prévisualiser les templates

Ils ne peuvent pas créer, modifier ou supprimer des templates.

### Reporter

Les reporters peuvent :
- Consulter la liste des templates disponibles
- Prévisualiser les templates

Ils ne peuvent pas utiliser les templates (car ils ne modèrent pas les demandes).

## Workflow

### Côté manager

1. Accéder à la gestion des templates via le tableau de bord instructeur
2. Créer un nouveau template en spécifiant :
   - Le type (demande de modifications ou refus)
   - Un titre court (max 50 caractères)
   - Le contenu avec des variables optionnelles
3. Prévisualiser le rendu avec des données d'exemple
4. Enregistrer le template (limité à 3 par type)

### Côté instructeur

1. Lors d'une demande de modifications ou d'un refus
2. Sélectionner un template dans la liste déroulante
3. Le contenu est automatiquement inséré dans le champ de texte avec les variables interpolées
4. Modifier le message si nécessaire
5. Soumettre la demande de modifications ou le refus

## Variables d'interpolation

Les templates supportent trois variables dynamiques qui sont automatiquement remplacées lors de l'utilisation :

- `%{demande_url}` : URL complète de la demande d'habilitation
- `%{demande_intitule}` : Intitulé/nom de la demande
- `%{demande_id}` : Identifiant numérique de la demande

### Exemple de template

**Titre** : Documents manquants

**Contenu** :
```
Bonjour,

Votre demande "%{demande_intitule}" nécessite des documents complémentaires.

Merci de les ajouter à votre demande en vous rendant sur : %{demande_url}

Cordialement,
L'équipe d'instruction
```

**Résultat après interpolation** :
```
Bonjour,

Votre demande "Accès API Entreprise pour simplifier les démarches" nécessite des documents complémentaires.

Merci de les ajouter à votre demande en vous rendant sur : https://datapass.api.gouv.fr/demandes/12345

Cordialement,
L'équipe d'instruction
```

## Architecture

### Modèles principaux

- **`MessageTemplate`** : Stocke les templates avec leur type, titre, contenu et référence au type d'habilitation
  - Enum `template_type` : `:refusal` (refus) ou `:modification_request` (demande de modifications)
  - Validation du titre (max 50 caractères)
  - Validation des variables (uniquement celles autorisées)
  - Validation du nombre maximum de templates (3 par type et par authorization_definition_uid)

- **`User`** : Extension pour gérer le rôle manager
  - Méthode `manager?(authorization_request_type)` : Vérifie si l'utilisateur est manager
  - Méthode `manager_roles` : Retourne tous les rôles manager de l'utilisateur
  - Scope `manager_for(authorization_request_type)` : Trouve tous les managers pour un type d'habilitation

### Services

- **`MessageTemplateInterpolator`** : Service d'interpolation des variables
  - `interpolate(content, authorization_request)` : Remplace les variables par les vraies valeurs
  - `preview(content)` : Remplace les variables par des valeurs d'exemple
  - `extract_variables(content)` : Extrait les variables présentes dans le contenu

### Organizers

Tous les organizers sont namespacés sous `Instructor::MessageTemplates` :

- **`Create`** : Crée un nouveau template avec validation
- **`Update`** : Met à jour un template existant
- **`Preview`** : Génère un aperçu avec des valeurs d'exemple

### Controllers

- **`Instruction::MessageTemplatesController`** : CRUD complet des templates
  - Vérification du rôle manager pour les actions de modification
  - Vérification de l'activation de la fonctionnalité via feature flag
  - Action `preview` pour afficher la modale de prévisualisation via Turbo Frame

- **`Instruction::RequestChangesOnAuthorizationRequestsController`** : Charge les templates de type `modification_request`
- **`Instruction::RefuseAuthorizationRequestsController`** : Charge les templates de type `refusal`

### Stimulus Controllers

- **`modal_controller.js`** : Gère l'ouverture/fermeture de la modale de prévisualisation
  - Supporte les Turbo Frames
  - Gère la fermeture via touche Escape ou clic extérieur

- **`message_template_selector_controller.js`** : Gère la sélection et l'application des templates
  - Récupère le contenu du template sélectionné
  - Interpole les variables avec les données de la demande
  - Remplit le champ textarea automatiquement

## Activation de la fonctionnalité

Pour activer cette fonctionnalité sur un type d'habilitation, ajouter dans le fichier YAML de configuration :

```yaml
features:
  message_templates: true
```

Exemple dans `config/authorization_definitions/api_entreprise.yml` :

```yaml
api_entreprise:
  name: "API Entreprise"
  # ... autres configurations
  features:
    message_templates: true
  # ...
```

## Routes principales

```ruby
# Gestion des templates (instructeurs managers)
GET    /instruction/templates-messages                    # Index
GET    /instruction/templates-messages/new                # Nouveau
POST   /instruction/templates-messages                    # Création
GET    /instruction/templates-messages/:id/modifier       # Édition
PATCH  /instruction/templates-messages/:id                # Mise à jour
DELETE /instruction/templates-messages/:id                # Suppression
GET    /instruction/templates-messages/:id/preview        # Prévisualisation

# Paramètre requis pour toutes les routes : authorization_definition_uid
```

## Tests

### RSpec

- `spec/models/message_template_spec.rb` : Validations et comportements du modèle
- `spec/models/user_spec.rb` : Tests du rôle manager
- `spec/services/message_template_interpolator_spec.rb` : Tests d'interpolation
- `spec/organizers/instructor/message_templates/` : Tests des trois organizers
- `spec/factories/message_templates.rb` : Factory pour les tests
- `spec/factories/users.rb` : Trait `:manager` ajouté

### Cucumber

- `features/instructeurs/templates_messages.feature` : Tests d'intégration complets
  - Gestion CRUD par les managers
  - Consultation par les instructeurs et reporters
  - Utilisation lors de demandes de modifications et refus
  - Validation des limites (3 templates max, variables valides)

## Points clés

### Contraintes et validations

- **Maximum 3 templates** par combinaison `authorization_definition_uid` + `template_type`
- **Titre limité à 50 caractères** pour faciliter l'affichage dans les sélecteurs
- **Variables autorisées uniquement** : `demande_url`, `demande_intitule`, `demande_id`
- **Authorization definition valide** : Le type d'habilitation doit exister

### Sécurité et isolation

- Les templates sont **isolés par type d'habilitation** (authorization_definition_uid)
- Les managers ne peuvent gérer que les templates des types d'habilitation pour lesquels ils ont le rôle
- Les instructeurs ne voient que les templates du type d'habilitation qu'ils instruisent

### Expérience utilisateur

- **Sélection optionnelle** : Les instructeurs peuvent choisir de ne pas utiliser de template
- **Modification possible** : Après sélection, le contenu peut être modifié avant soumission
- **Prévisualisation en temps réel** : La modale de prévisualisation montre le rendu final avec des données d'exemple
- **Interface Turbo** : Utilisation de Turbo Frames pour une expérience fluide sans rechargement

### Feature flag

- La fonctionnalité est **désactivée par défaut**
- Activation au niveau de chaque type d'habilitation via `features.message_templates`
- Si désactivé, les routes retournent une erreur d'autorisation

## Migration de la base de données

```bash
# Créer la table message_templates
rails db:migrate

# En test
RAILS_ENV=test rails db:migrate
```

La table contient :
- `id` : Identifiant unique
- `authorization_definition_uid` : Type d'habilitation (string)
- `template_type` : Type de template (integer enum: 0 = refusal, 1 = modification_request)
- `title` : Titre du template (string, max 50 caractères)
- `content` : Contenu du template avec variables (text)
- `created_at` et `updated_at` : Horodatage

Index sur `[authorization_definition_uid, template_type]` pour optimiser les requêtes.

## Évolutions futures possibles

- Ajouter des variables supplémentaires (organisation, contact, etc.)
- Permettre des templates partagés entre plusieurs types d'habilitation
- Historique des utilisations de templates
- Statistiques sur les templates les plus utilisés
- Templates suggérés en fonction du contexte de la demande
