# Plan — DP-1684 Créer l’interface qui gère l’état actuel

Ticket : https://linear.app/pole-api/issue/DP-1684
Figma : https://www.figma.com/design/QnOT1DwTE9o4Nv4aMs52VU/Datapass-V3?node-id=3827-5882
Branche : `feature/dp-1684-creer-linterface-qui-gere-letat-actuel`
Base : `feature/dp-1612-shaping-droits-de-niveau-fd` (introduit les POROs `RoleHierarchy` et `RoleSet` + refactor de `User`).

## APIs disponibles depuis la base 1612

- `RoleHierarchy::IMPLIES` : hiérarchie (manager → instructor → reporter ; developer → reporter).
- `RoleHierarchy.qualifying_roles(kind)` : renvoie la liste des rôles qui satisfont `kind`.
- `RoleSet#covers?(definition_id = nil)` / `#any?` / `#definition_ids` / `#authorization_request_types` / `#authorization_definitions`.
- `User#roles_for(kind)` → `RoleSet` mémoïsé.
- `User#definition_ids_for(kind)` et `User#authorization_definition_roles_as(kind)` (helpers).
- `User#manager?(definition_id = nil)` / `#instructor?(...)` / `#reporter?(...)` / `#developer?`.
- `User.manager_for(type)` / `.instructor_for(type)` / `.reporter_for(type)` / `.developer_for(type)`.

Conséquences pour ce plan :
- On n’ajoute **pas** de scope `with_roles_on_definitions` ad hoc : on s’appuie sur `RoleSet`.
- On n’ajoute **pas** de helper `managed_authorization_definitions` : on utilise `current_user.authorization_definition_roles_as(:manager)`.
- On n’utilise **plus** les helpers supprimés (`manager_roles`, `instructor_roles`, …) : on utilise `roles_for(kind).definition_ids` ou `roles_for(kind).authorization_definitions`.

## Contexte fonctionnel

Le ticket demande une interface située sur `/instruction/gestion-des-droits` permettant à un **manager** (utilisateur possédant un rôle `<definition_id>:manager`) de gérer les droits d’autres utilisateurs **sur les définitions qu’il manage**.

### Contraintes métier (issues du ticket, de DP-1613 et des réponses à la revue)

1. Un manager ne peut **jamais** attribuer le rôle `admin`.
2. Un manager ne peut attribuer/retirer des droits que sur **les définitions dont il est lui-même manager**.
3. Un manager ne peut **pas s’enlever lui-même** le rôle `manager` — on applique cette règle en **excluant le manager courant de la liste** (il ne peut donc pas se retirer ses propres droits depuis l’UI).
4. Le rôle `developer` **n’est pas proposé** dans ce ticket : les admins s’en occupent. On limite les rôles sélectionnables à `reporter`, `instructor`, `manager`.
5. Pas de gestion au niveau FD dans ce ticket (on reste au niveau définition, stockage actuel `definition_id:role_type`).
6. **Pas d’onglets** — on n’affiche pas la liste des utilisateurs sans droits dans ce ticket.
7. **Pas de recherche** dans cette itération (fonctionnalité reportée).
8. Intitulés imposés :
    - bouton d’ajout : « Ajouter des droits à un utilisateur sans droits »
    - bouton de suppression : « Supprimer tous les droits de l’utilisateur »

### Écrans Figma (3 états)

- `3817:2587` — Liste avec résultats (tableau Email / Nom / Prénom / Droits / Rôles / Actions + bouton « Ajouter un utilisateur » + barre de recherche).
- `3917:21142` — Liste empty state (« Aucun utilisateur ne possède de droits pour l’instant » + bouton).
- `3917:5226` — Formulaire modifier (Informations d’identité en lecture seule + section « Les droits » avec couples (Portée, Rôle) et bouton « + Ajouter un droit », + bouton « Supprimer l’utilisateur » en haut, + « Annuler » / « Valider les modifications » en bas).

**Adaptations vs Figma** (imposées par le ticket) :
- Titre « Gestion des droits » sans sous-titre « API Entreprise » (le manager peut couvrir plusieurs définitions).
- Pas d’onglets « Utilisateurs avec des droits » / « Utilisateurs sans droits ».
- Libellés des boutons modifiés (cf. ci-dessus).

## Règles techniques DataPass (rappel)

- TDD : modèles/scopes → services/organizers → contrôleurs/vues → features cucumber.
- Pundit pour l’autorisation (dans les contrôleurs).
- Organizers (interactor) pour la logique métier, `AdminEvent` pour le tracking.
- DSFRFormBuilder pour les formulaires.
- ViewComponents en Atomic Design (atoms/molecules/organisms/dsfr) avec previews sur objets réels des seeds.
- **Avant de créer un ViewComponent maison : privilégier les composants du gem `dsfr-view-components` et les helpers existants.** Ne créer un composant que lorsqu’il n’existe aucun équivalent (ou pas suffisant) dans le gem, que le besoin est réutilisé à plusieurs endroits, ou que la logique justifie une encapsulation.
- RGAA : labels explicites, `aria-*`, focus management, contraste, structure sémantique (`<table>`, `<th scope>`, `<nav>`, etc.).
- Pas de commentaires, noms explicites, apostrophes ’ et guillemets « », fin de fichier avec newline.

## Inventaire des composants / helpers réutilisables

### Fournis par le gem `dsfr-view-components` 4.1.3 (via `DsfrComponentsHelper`)

| Helper | Composant | Usage prévu dans ce ticket |
|--------|-----------|----------------------------|
| `dsfr_breadcrumbs` | `DsfrComponent::BreadcrumbsComponent` (`renders_many :breadcrumbs`) | Fil d’Ariane des pages `new` / `edit` / `confirm_destroy` |
| `dsfr_callout` | `DsfrComponent::CalloutComponent` | Bloc d’aide « Reporter / Instructeur / Manager » dans le formulaire |
| `dsfr_search` | `DsfrComponent::SearchComponent` (`url:`, `name:`, `label_text:`, `button_text:`, `value:`) | Barre de recherche de la liste |
| `dsfr_modal` | `DsfrComponent::ModalComponent` (`title:`, `renders_one :header`, `renders_many :buttons`) | Modale de confirmation de suppression si on utilise l’approche modale |
| `dsfr_alert` | `DsfrComponent::AlertComponent` | Messages d’erreur inline si besoin (`FlashAlertComponent` couvre déjà les flashes) |
| `dsfr_button` | `DsfrComponent::ButtonComponent` | Boutons `<button>` simples (non utilisé pour les liens — préférer `link_to class: 'fr-btn…'`) |
| `dsfr_badge` | `DsfrComponent::BadgeComponent` | **Inadapté ici** : statuts limités à `%i[success error info warning new]`, ne supporte pas les couleurs DSFR étendues (`purple-glycine`, `pink-tuile`, `yellow-tournesol`) visibles dans la maquette. On passe par un helper local + classes `fr-badge--<color>`. |
| `dsfr_tag` | `DsfrComponent::TagComponent` | Écarté : orienté filtres / pills, pas les badges de rôle de la maquette. |
| `dsfr_tabs` / `dsfr_notice` / `dsfr_stepper` / `dsfr_side_menu` / … | — | Non requis dans ce ticket. |

### Fournis par le projet DataPass

| Élément | Chemin | Usage |
|---------|--------|-------|
| `DsfrFormBuilder` | `app/form_builders/dsfr_form_builder.rb` | `f.dsfr_email_field`, `f.dsfr_text_field`, `f.dsfr_select` — tous les champs du formulaire |
| `FlashAlertComponent` | `app/components/flash_alert_component.rb` | Succès / erreur post-submit — déjà appelé par le layout |
| Shared modal + turbo-frame | `app/views/shared/_modal.html.erb` + `app/helpers/dsfr/modal.rb` (`dsfr_main_modal_button`, `dsfr_modal_button`) | Pattern existant pour charger dynamiquement un contenu de modale via `turbo-frame` — candidate pour `confirm_destroy` |
| `InstructorMenuComponent` | `app/components/instructor_menu_component.rb` | À étendre avec `show_user_rights:` |

### Règle générale appliquée à ce plan

- Tableau DSFR : **pas de composant maison**. On utilise du markup direct `fr-table fr-table--bordered` en ERB dans `index.html.erb` (un seul lieu d’utilisation, pas de logique complexe).
- Empty state : **pas de composant maison**. Partial `_empty_state.html.erb` ou rendu inline.
- Badge de rôle : **helper view** `role_badge(role)` (ou partial `_role_badge.html.erb`) qui sort un `<p class="fr-badge fr-badge--sm fr-badge--<color>">`. Les couleurs restent centralisées là.
- Formulaire : ERB + `DsfrFormBuilder` + `dsfr_breadcrumbs` + `dsfr_callout`. Un seul ViewComponent maison se justifie : **la ligne `(Portée, Rôle)` dupliquée côté Stimulus template et côté serveur** (`Instruction::UserRights::RightFieldComponent`).
- Confirmation de suppression : on réutilise le pattern `shared/_modal.html.erb` + turbo-frame (cohérent avec le reste du projet).

---

## Découpage CRUD en 4 étapes

Chaque étape est livrable indépendamment (une PR possible par étape). Chaque étape se conclut par `bundle exec rubocop` + `bundle exec rspec` + `bundle exec cucumber` verts avant passage à la suivante.

---

## Étape 1 — READ : afficher la liste des utilisateurs avec droits

Objectif : un manager se rend sur `/instruction/gestion-des-droits` et voit le tableau des utilisateurs qui possèdent des droits sur au moins une définition qu’il manage.

### 1.1 Scope de listing

Ajouter dans `app/models/user.rb` un unique scope dédié à la recherche des utilisateurs ayant au moins un rôle sur l’un des `definition_ids` passés en argument :

```ruby
scope :with_any_role_on, lambda { |definition_ids|
  ids = Array(definition_ids)
  return none if ids.empty?

  where(
    'EXISTS (SELECT 1 FROM unnest(roles) AS role WHERE split_part(role, \':\', 1) IN (?))',
    ids
  )
}
```

- **But** : filtrer les utilisateurs qui ont au moins un rôle scopé sur une des définitions passées — inclut donc reporter/instructor/manager/developer sur ces définitions. N’inclut pas les admins purs (sans rôle scopé) — cohérent avec le ticket : on ne gère pas les admins ici.
- Spec `spec/models/user_spec.rb` : renvoie les bons users, exclut ceux avec uniquement des rôles hors périmètre, exclut les utilisateurs sans rôle, renvoie `User.none` pour un tableau vide.

### 1.2 Pas de nouveau helper « managed_authorization_definitions »

Plus nécessaire : la base 1612 fournit déjà `current_user.authorization_definition_roles_as(:manager)` (qui renvoie les `AuthorizationDefinition` correspondant aux rôles manager de l’utilisateur) et `current_user.definition_ids_for(:manager)` pour les ids seuls. On les utilise directement dans le contrôleur / la policy / la vue.

### 1.3 Policy Pundit

`app/policies/instruction/user_right_policy.rb` (ou `user_with_role_policy.rb` ; je propose `UserRightPolicy` pour rester cohérent avec la terminologie du ticket « gestion des droits ») :

```ruby
class Instruction::UserRightPolicy < ApplicationPolicy
  def enabled?
    user.manager?
  end

  def index?  = enabled?
  def show?   = enabled?
  def new?    = enabled?
  def create? = enabled?
  def edit?   = enabled? && record != user && can_manage_any_role?(record)
  def update? = edit?
  def destroy? = edit?

  private

  def can_manage_any_role?(target_user)
    managed_ids = user.definition_ids_for(:manager)
    (target_user.roles.map { |r| r.split(':').first } & managed_ids).any?
  end
end
```

- Le manager ne peut jamais cibler son propre compte : `record != user` dans `edit?` suffit à couvrir la règle « pas d’auto-suppression du rôle manager » (en plus du filtrage de la liste qui empêche l’accès via l’UI).
- Spec complet : un reporter n’a pas accès, un manager a accès, la policy rejette l’édition du manager lui-même (URL forgée) et l’édition d’un utilisateur qui n’a aucun droit sur les définitions gérées.

### 1.4 Route

Dans `config/routes.rb`, namespace `:instruction` :

```ruby
resources :user_rights, only: %i[index new create edit update destroy], path: 'gestion-des-droits'
```

- Nom du contrôleur : `Instruction::UserRightsController`.

### 1.5 Contrôleur

`app/controllers/instruction/user_rights_controller.rb` :

```ruby
class Instruction::UserRightsController < InstructionController
  before_action :authorize_user_rights!

  def index
    @managed_definitions = current_user.authorization_definition_roles_as(:manager)
    @users = User.with_any_role_on(@managed_definitions.map(&:id))
                 .where.not(id: current_user.id)
                 .includes(:organizations)
                 .order(:email)
  end

  private

  def authorize_user_rights!
    authorize [:instruction, :user_right]
  end
end
```

- **Pas de recherche** dans cette itération (confirmée en revue, à implémenter plus tard). Pas de `params[:q]`, pas de `dsfr_search` dans la vue.
- Le manager courant est exclu de sa propre liste (`where.not(id: current_user.id)`).
- Spec/feature : contrôleur se contente d’alimenter la vue, on testera via cucumber.

### 1.6 Vue `index.html.erb`

`app/views/instruction/user_rights/index.html.erb` — **aucun ViewComponent maison**, on s’appuie sur les helpers du gem + markup DSFR direct :

- `set_title! t('page_titles.instruction.user_rights.index')`.
- En-tête DSFR `fr-container` avec `h1` « Gestion des droits » et `content_for(:header_action)` → `link_to t('.add_cta'), new_instruction_user_right_path, class: 'fr-btn'`.
- Pas de barre de recherche dans cette itération.
- Si `@users.empty?` → empty state en ERB inline (pas de composant dédié) :
  ```erb
  <div class="fr-py-6w fr-align-center">
    <p><%= t('.empty_state') %></p>
    <%= link_to t('.add_cta'), new_instruction_user_right_path,
                class: 'fr-btn fr-btn--primary fr-icon-user-add-line fr-btn--icon-left' %>
  </div>
  ```
- Sinon → tableau DSFR en ERB direct `fr-table fr-table--bordered` :
  - Colonnes : Email / Nom / Prénom / Droits / Rôles / Actions.
  - Une ligne logique par couple `(user, definition)`. La maquette Figma montre des cellules fusionnées quand un user a plusieurs droits : on reproduit le comportement via `rowspan` calculé à partir de `user.roles.select { |r| @managed_definitions.map(&:id).include?(r.split(':').first) }.group_by { |r| r.split(':').first }`.
  - Colonne « Rôles » : helper `role_badge(role)` (voir 1.7) rend `<p class="fr-badge fr-badge--sm fr-badge--<color>">`.
  - Colonne « Actions » : icônes `fr-btn fr-btn--tertiary-no-outline fr-btn--sm fr-icon-edit-line` + `fr-icon-delete-line`, avec `aria-label` explicite (« Modifier les droits de <email> », « Supprimer tous les droits de <email> »), masquées si `policy([:instruction, :user_right]).edit?(user)` est faux (cas du manager lui-même pour la suppression).

### 1.7 Helper pour les badges de rôle (pas de ViewComponent)

Le composant `dsfr_badge` du gem est limité à `%i[success error info warning new]` — il n’accepte pas les couleurs DSFR étendues (`purple-glycine`, `pink-tuile`, `yellow-tournesol`) utilisées dans la maquette. On crée un simple helper `app/helpers/instruction/user_rights_helper.rb` :

```ruby
module Instruction::UserRightsHelper
  ROLE_COLORS = {
    'manager'    => 'purple-glycine',
    'instructor' => 'pink-tuile',
    'reporter'   => 'yellow-tournesol',
  }.freeze

  def role_badge(role_type)
    content_tag(:p,
      t("instruction.user_rights.roles.#{role_type}"),
      class: "fr-badge fr-badge--sm fr-badge--#{ROLE_COLORS.fetch(role_type)}")
  end
end
```

- Spec rapide `spec/helpers/instruction/user_rights_helper_spec.rb` : chaque clé produit le bon HTML.
- Pas de ViewComponent dédié ni de preview — le helper est trop simple pour justifier l’encapsulation.

### 1.8 Menu instruction

Modifier `app/components/instructor_menu_component.rb` pour ajouter `show_user_rights:` :

```ruby
def initialize(show_drafts:, show_templates:, show_user_rights:)
  @show_drafts = show_drafts
  @show_templates = show_templates
  @show_user_rights = show_user_rights
end
```

Dans `instructor_menu_component.html.erb` ajouter un `<li>` conditionnel avec lien vers `instruction_user_rights_path` et label `t('layouts.header.menu.instruction.user_rights')` → « Gestion des droits ».

Dans `app/views/layouts/header/_menu.html.erb` :

```erb
<%= render InstructorMenuComponent.new(
  show_drafts: policy([:instruction, :instructor_draft_request]).enabled?,
  show_templates: policy([:instruction, :message_template]).index?,
  show_user_rights: policy([:instruction, :user_right]).enabled?,
) %>
```

### 1.9 i18n

Ajouter dans `config/locales/instruction.fr.yml` :

```yaml
instruction:
  user_rights:
    index:
      title: "Gestion des droits"
      empty_state: "Aucun utilisateur ne possède de droits pour l’instant"
      add_cta: "Ajouter des droits à un utilisateur sans droits"
      table:
        header:
          email: "Email"
          family_name: "Nom"
          given_name: "Prénom"
          rights: "Droits"
          roles: "Rôles"
          actions: "Actions"
        edit_aria: "Modifier les droits de %{email}"
        destroy_aria: "Supprimer tous les droits de %{email}"
    roles:
      manager: "Manager"
      instructor: "Instructeur"
      reporter: "Reporter"
```

Ajouter la clé `layouts.header.menu.instruction.user_rights: "Gestion des droits"` et `page_titles.instruction.user_rights.index: "Datapass — Gestion des droits"` dans les fichiers correspondants.

### 1.10 Feature cucumber

`features/instruction/gestion_des_droits/je_vois_la_liste_des_droits.feature` :

```gherkin
# language: fr
Fonctionnalité: Espace instruction — lister les utilisateurs avec droits

  Contexte:
    Sachant que je suis un manager pour "API Entreprise"
    Et que je me connecte

  Scénario: Je vois les utilisateurs avec des droits sur les définitions que je manage
    Quand il y a l'utilisateur "user1@gouv.fr" avec le rôle "Instructeur" pour "API Entreprise"
    Et qu'il y a l'utilisateur "user2@gouv.fr" avec le rôle "Rapporteur" pour "API Particulier"
    Et que je me rends sur la "Gestion des droits"
    Alors la page contient "user1@gouv.fr"
    Et la page ne contient pas "user2@gouv.fr"

  Scénario: Empty state lorsque personne n'a de droits
    Quand je me rends sur la "Gestion des droits"
    Alors la page contient "Aucun utilisateur ne possède de droits pour l’instant"
    Et le bouton "Ajouter des droits à un utilisateur sans droits" est visible

  Scénario: Je ne me vois pas dans ma propre liste
    Quand je me rends sur la "Gestion des droits"
    Alors la page ne contient pas mon email

  Scénario: Un reporter n'a pas accès à la gestion des droits
    Étant donné que je suis "reporter" pour "API Entreprise"
    Quand je tente d'accéder à "/instruction/gestion-des-droits"
    Alors je suis redirigé vers le tableau de bord
```

Ajouter les step definitions manquantes dans `features/step_definitions/` si besoin (navigation vers « Gestion des droits », redirection).

### 1.11 Critères de recette étape 1

- [ ] `bundle exec rubocop` OK
- [ ] `bundle exec rspec` OK (specs modèle + policy + components)
- [ ] `bundle exec cucumber features/instruction/gestion_des_droits/je_vois_la_liste_des_droits.feature` OK
- [ ] Axe-core / validation manuelle RGAA : navigation clavier, `aria-label`, headers tableau, contraste badges.
- [ ] Le menu instruction affiche « Gestion des droits » pour un manager, pas pour un reporter.

---

## Étape 2 — CREATE : ajouter des droits à un utilisateur sans droits

Objectif : depuis la liste, un manager clique sur « Ajouter des droits à un utilisateur sans droits », saisit un email, ajoute un ou plusieurs couples (Portée, Rôle), valide, et l’utilisateur apparaît dans la liste.

### 2.1 Form object

Créer `app/forms/instruction/user_right_form.rb` (ActiveModel) — plus simple que le textarea admin :

```ruby
class Instruction::UserRightForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :email, :string
  attribute :rights, default: -> { [] }  # Array<Hash{definition_id, role_type}>

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :at_least_one_right
  validate :rights_scoped_to_managed_definitions
  validate :no_admin_role

  def initialize(manager:, user: nil, **attrs)
    @manager = manager
    @user = user
    super(**attrs)
    @rights = Array(rights)
  end
  # ...
end
```

- `rights` attendu au format `[{definition_id: 'api_entreprise', role_type: 'reporter'}, ...]`.
- Validations :
  - email présent, utilisateur existant en base (sinon erreur « L’utilisateur n’existe pas »).
  - au moins un droit (sauf dans le cas destroy, qui passe par un autre chemin).
  - chaque `definition_id` appartient à `manager.definition_ids_for(:manager)`.
  - `role_type` est dans `%w[reporter instructor manager]` (jamais `admin`, jamais `developer` dans cette itération).
- Méthode `to_roles` → `["api_entreprise:reporter", ...]`.
- Spec complet.

### 2.2 Organizer

Créer `app/organizers/instruction/update_user_rights.rb` :

```ruby
class Instruction::UpdateUserRights < ApplicationOrganizer
  before do
    context.admin_entity_key = :user
    context.admin_event_name = 'user_rights_changed_by_manager'
    context.admin_before_attributes = { roles: context.user.roles }
  end

  organize Instruction::MergeManagedRoles,
    Admin::TrackEvent,
    Admin::NotifyAdminsForRolesUpdate

  after { context.user.save }
end
```

Et l’interactor `app/interactors/instruction/merge_managed_roles.rb` :

```ruby
class Instruction::MergeManagedRoles < ApplicationInteractor
  def call
    managed_ids = context.manager.definition_ids_for(:manager)

    untouched = context.user.roles.reject { |r| managed_ids.include?(r.split(':').first) }
    incoming  = context.new_roles.select   { |r| managed_ids.include?(r.split(':').first) }
    context.user.roles = (untouched + incoming).uniq
  end
end
```

- **Important** : un manager ne doit pas pouvoir altérer les rôles d’un utilisateur sur des définitions qu’il ne manage pas. On conserve donc les rôles « hors périmètre » existants et on ne met à jour que la portion gérée par le manager.
- Spec unitaire pour vérifier ce comportement de merge.

### 2.3 Contrôleur — actions new/create

Étendre `Instruction::UserRightsController` :

```ruby
def new
  @form = Instruction::UserRightForm.new(manager: current_user)
end

def create
  @form = Instruction::UserRightForm.new(manager: current_user, **form_params)
  user = User.find_by(email: @form.email)

  if user.nil?
    @form.errors.add(:email, :not_found)
    return render :new, status: :unprocessable_content
  end
  unless @form.valid?
    return render :new, status: :unprocessable_content
  end

  organizer = Instruction::UpdateUserRights.call(
    manager: current_user, user: user, new_roles: @form.to_roles
  )
  if organizer.success?
    redirect_to instruction_user_rights_path,
      flash: { success: { title: t('.success', email: user.email) } }
  else
    flash.now[:error] = { title: t('.error'), message: organizer.error }
    render :new, status: :unprocessable_content
  end
end

private

def form_params
  params.require(:instruction_user_right_form)
        .permit(:email, rights: [:definition_id, :role_type])
        .to_h
        .symbolize_keys
end
```

### 2.4 Vue `new.html.erb` + partial `_form.html.erb`

Structure reproduisant la maquette `3917:5226` (en mode ajout, les champs identité sont vides et éditables) :

- Fil d’Ariane via `dsfr_breadcrumbs` (gem) :
  ```erb
  <%= dsfr_breadcrumbs do |c|
        c.with_breadcrumb(label: t('layouts.header.menu.instruction.user_rights'),
                          href: instruction_user_rights_path)
        c.with_breadcrumb(label: t('.breadcrumb'))
      end %>
  ```
- `h1` « Ajouter des droits à un utilisateur sans droits ».
- Card « Informations d’identité » (markup DSFR direct, pas de composant maison) : `f.dsfr_email_field :email` (labellisé « Email », required).
- Card « Les droits » :
  - Texte d’aide via `dsfr_callout(title: nil, icon_name: :none) { t('.rights_hint') }` : « Reporter (consultation) — Instructeur (reporter + modification) — Manager (instructeur + gestion des droits) ».
  - Liste dynamique de couples (Portée, Rôle) : rendu du composant `Instruction::UserRights::RightFieldComponent` (voir 2.6) autant de fois qu’il y a d’entrées dans `@form.rights` (minimum 1). **Seul composant maison justifié** car il est dupliqué côté template Stimulus et côté rendu initial.
  - Chaque couple :
    - Select « Portée des droits » contenant uniquement `current_user.authorization_definition_roles_as(:manager)`.
    - Select « Rôle » contenant `%w[reporter instructor manager]` (donc **jamais `admin`** ni `developer`).
  - Bouton « + Ajouter un droit » — gestion côté client via Stimulus contrôleur `user-rights-form` (ajoute une nouvelle paire de selects clonée à partir d’un `<template>`). Fallback no-JS : soumettre avec `_add_right=true` ajoute un couple vide.
- Boutons bas de page : « Annuler » (`link_to class: 'fr-btn fr-btn--secondary'`) et submit `f.submit t('.submit'), class: 'fr-btn fr-btn--primary'`.

### 2.5 Stimulus controller

`app/javascript/controllers/user_rights_form_controller.js` :

- `add()` clone le `<template data-user-rights-form-target="template">` et incrémente les indices `rights[N][...]`.
- `remove(event)` retire la ligne ciblée et renumérote.
- Reste conforme à StandardJS (cf. `make js-lint`).

### 2.6 ViewComponent (un seul, justifié par la duplication Stimulus)

- `app/components/instruction/user_rights/right_field_component.{rb,html.erb}` (molecule) — une ligne (select Portée + select Rôle + bouton supprimer). Reçoit `index:`, `definition_id:`, `role_type:`, `managed_definitions:`.
  - Rendu sur le serveur pour les droits initiaux (mode edit).
  - Rendu dans un `<template data-user-rights-form-target="template">` pour le clonage Stimulus (index `__INDEX__` remplacé en JS).
- **Pas de `form_component` maison** : le formulaire complet reste dans `_form.html.erb` en ERB direct, avec `DsfrFormBuilder`, `dsfr_breadcrumbs`, `dsfr_callout`.
- Preview `spec/components/previews/instruction/user_rights/right_field_component_preview.rb` avec objets réels des seeds (cf. `Seeds#api_entreprise_instructor`).

### 2.7 i18n

Ajouter :

```yaml
instruction:
  user_rights:
    new:
      title: "Ajouter des droits à un utilisateur sans droits"
      breadcrumb: "Ajouter des droits"
      identity_section: "Informations d’identité"
      rights_section: "Les droits"
      rights_hint: "Reporter (consultation) — Instructeur (reporter + modification) — Manager (instructeur + gestion des droits)"
      scope_label: "Portée des droits"
      role_label: "Rôle"
      add_right: "Ajouter un droit"
      cancel: "Annuler"
      submit: "Valider les modifications"
    create:
      success: "Les droits de %{email} ont été mis à jour"
      error: "Impossible d’enregistrer les droits"
    errors:
      user_not_found: "Aucun utilisateur n’existe avec cet email"
      definition_not_managed: "Vous n’êtes pas manager de cette définition"
      admin_role_forbidden: "Le rôle administrateur ne peut pas être attribué ici"
      at_least_one_right: "Au moins un droit doit être défini"
```

### 2.8 Feature cucumber

`features/instruction/gestion_des_droits/j_ajoute_des_droits.feature` :

```gherkin
# language: fr
Fonctionnalité: Espace instruction — ajouter des droits à un utilisateur

  Contexte:
    Sachant que je suis un manager pour "API Entreprise"
    Et que je me connecte

  Scénario: J'ajoute un premier rôle à un utilisateur sans droits
    Quand il y a l'utilisateur "nouveau@gouv.fr" sans rôle
    Et que je me rends sur la "Gestion des droits"
    Et que je clique sur "Ajouter des droits à un utilisateur sans droits"
    Et que je remplis "Email" avec "nouveau@gouv.fr"
    Et que je sélectionne "API Entreprise" pour "Portée des droits"
    Et que je sélectionne "Reporter" pour "Rôle"
    Et que je clique sur "Valider les modifications"
    Alors il y a un message de succès contenant "mis à jour"
    Et la page contient "nouveau@gouv.fr"
    Et la page contient le badge "Reporter"

  Scénario: J'ajoute plusieurs droits en une fois
    Quand il y a l'utilisateur "multi@gouv.fr" sans rôle
    Et que je me rends sur "Ajouter des droits à un utilisateur sans droits"
    Et que je remplis "Email" avec "multi@gouv.fr"
    Et que je sélectionne "API Entreprise" et "Reporter" sur le premier droit
    Et que je clique sur "Ajouter un droit"
    Et que je sélectionne "API Entreprise" et "Instructeur" sur le deuxième droit
    Et que je clique sur "Valider les modifications"
    Alors l'utilisateur "multi@gouv.fr" a les rôles "api_entreprise:reporter,api_entreprise:instructor"

  Scénario: Je ne peux pas ajouter des droits à un utilisateur inexistant
    Quand je me rends sur "Ajouter des droits à un utilisateur sans droits"
    Et que je remplis "Email" avec "inconnu@gouv.fr"
    Et que je sélectionne "API Entreprise" et "Reporter"
    Et que je clique sur "Valider les modifications"
    Alors il y a un message d'erreur contenant "n’existe"

  Scénario: La liste de portées ne contient pas les définitions que je ne manage pas
    Étant donné qu'il existe la définition "API Particulier"
    Quand je me rends sur "Ajouter des droits à un utilisateur sans droits"
    Alors le select "Portée des droits" contient "API Entreprise"
    Et le select "Portée des droits" ne contient pas "API Particulier"

  Scénario: La liste des rôles ne contient pas "admin"
    Quand je me rends sur "Ajouter des droits à un utilisateur sans droits"
    Alors le select "Rôle" ne contient pas "admin"
```

### 2.9 Critères de recette étape 2

- [ ] Linter + specs + cucumber verts.
- [ ] Vérif manuelle RGAA : selects labellisés, messages d’erreur reliés aux champs via `aria-describedby`, focus repositionné sur nouvelle ligne quand on clique « Ajouter un droit ».
- [ ] Axe-core sans violation.
- [ ] Test manuel : impossibilité d’injecter un `role_type=admin` via inspecteur (cf. validation côté serveur).

---

## Étape 3 — UPDATE : modifier les droits d’un utilisateur

Objectif : depuis la liste, clic sur l’icône « Modifier » ouvre le même formulaire pré-rempli. On peut ajouter, retirer, remplacer des droits dans le périmètre du manager.

### 3.1 Contrôleur — edit/update

```ruby
def edit
  @user = User.find(params[:id])
  authorize [:instruction, :user_right], :edit?
  @form = Instruction::UserRightForm.new(
    manager: current_user,
    user: @user,
    email: @user.email,
    rights: rights_in_scope(@user),
  )
end

def update
  @user = User.find(params[:id])
  authorize [:instruction, :user_right], :update?
  @form = Instruction::UserRightForm.new(
    manager: current_user, user: @user, **form_params
  )
  return render :edit, status: :unprocessable_content unless @form.valid?

  Instruction::UpdateUserRights.call(
    manager: current_user, user: @user, new_roles: @form.to_roles
  )
  redirect_to instruction_user_rights_path,
    flash: { success: { title: t('.success', email: @user.email) } }
end

private

def rights_in_scope(user)
  managed_ids = current_user.definition_ids_for(:manager)
  user.roles.filter_map do |role|
    definition_id, role_type = role.split(':')
    next unless managed_ids.include?(definition_id)

    { definition_id: definition_id, role_type: role_type }
  end
end
```

### 3.2 Vue `edit.html.erb`

- Reprendre le même partial `_form.html.erb` que `new`.
- Fil d’Ariane « Gestion des droits » > « Modifier des droits ».
- `h1` « Modifier des droits » (cf. Figma).
- Champ email en **readonly** (`disabled: true`) et champs nom/prénom readonly (affichage seulement).
- Bouton « Supprimer tous les droits de l’utilisateur » en haut à droite (`content_for :header_action`) via `dsfr_main_modal_button` (voir étape 4).
- Form identique à l’étape 2 mais pré-rempli avec `rights_in_scope(@user)`.

### 3.3 Contrainte auto-suppression manager

**Aucun code supplémentaire nécessaire** : la règle est couverte à deux niveaux :
1. Le contrôleur `index` exclut le manager courant via `where.not(id: current_user.id)` → pas de lien « Modifier » / « Supprimer » sur sa propre ligne.
2. La policy (`edit? = record != user && …`) bloque toute tentative d’édition via URL forgée.

Pas de validation dans le form object — elle serait inatteignable.

### 3.4 Feature cucumber

`features/instruction/gestion_des_droits/je_modifie_des_droits.feature` :

```gherkin
# language: fr
Fonctionnalité: Espace instruction — modifier les droits

  Contexte:
    Sachant que je suis un manager pour "API Entreprise"
    Et que je me connecte

  Scénario: Je modifie un rôle existant
    Quand il y a l'utilisateur "eva@gouv.fr" avec le rôle "Reporter" pour "API Entreprise"
    Et que je me rends sur la "Gestion des droits"
    Et que je clique sur "Modifier les droits de eva@gouv.fr"
    Alors le select "Rôle" est positionné sur "Reporter"
    Quand je sélectionne "Instructeur" pour "Rôle"
    Et que je clique sur "Valider les modifications"
    Alors l'utilisateur "eva@gouv.fr" a le rôle "api_entreprise:instructor"

  Scénario: Je ne peux pas éditer mon propre utilisateur (URL forgée)
    Quand je tente d'accéder à l'édition de mon propre utilisateur via URL
    Alors je suis redirigé avec un message d'erreur d'autorisation

  Scénario: Je ne peux pas modifier les droits d'un utilisateur sur une définition hors de mon périmètre
    Quand il y a l'utilisateur "externe@gouv.fr" avec le rôle "Reporter" pour "API Particulier"
    Et que je me rends sur la "Gestion des droits"
    Alors la page ne contient pas "externe@gouv.fr"

  Scénario: Les rôles hors de mon périmètre ne sont pas modifiés lorsque je modifie un utilisateur qui en a
    Quand il y a l'utilisateur "mixte@gouv.fr" avec les rôles "api_entreprise:reporter,api_particulier:reporter"
    Et que je me rends sur la "Gestion des droits"
    Et que je clique sur "Modifier les droits de mixte@gouv.fr"
    Et que je sélectionne "Instructeur" pour "Rôle"
    Et que je clique sur "Valider les modifications"
    Alors l'utilisateur "mixte@gouv.fr" a les rôles "api_entreprise:instructor,api_particulier:reporter"
```

### 3.5 Critères de recette étape 3

- [ ] Spec de la policy couvre le refus d’édition du manager lui-même.
- [ ] Spec de l’interactor `MergeManagedRoles` couvre la non-altération des rôles hors périmètre.
- [ ] Cucumber features vertes.
- [ ] Vérif manuelle : aucune ligne « moi-même » dans la liste ; URL forgée vers `edit` renvoie 403.

---

## Étape 4 — DELETE : supprimer tous les droits d’un utilisateur

Objectif : depuis la liste ou la page d’édition, un manager peut retirer **tous les droits** (dans son périmètre) d’un utilisateur. Les rôles hors périmètre ne sont pas touchés. Un manager ne peut pas se supprimer lui-même si cela revient à retirer son rôle manager.

### 4.1 Contrôleur — destroy

```ruby
def destroy
  @user = User.find(params[:id])
  authorize [:instruction, :user_right], :destroy?

  Instruction::UpdateUserRights.call(
    manager: current_user,
    user: @user,
    new_roles: [],  # new_roles vide dans le périmètre → l'interactor conserve les autres
  )

  redirect_to instruction_user_rights_path,
    flash: { success: { title: t('.success', email: @user.email) } }
end
```

- La policy `destroy?` rejette déjà `user == current_user` (étape 1.3) — pas de double garde côté contrôleur.
- L’interactor `MergeManagedRoles` garantit que seuls les rôles dans le périmètre du manager sont supprimés. Rien à changer côté organizer.

### 4.2 Confirmation côté UI

On réutilise le pattern existant du projet : modale via `app/views/shared/_modal.html.erb` + turbo-frame, déclenchée par `dsfr_main_modal_button` (`app/helpers/dsfr/modal.rb`). Cela évite :
- une route `confirm_destroy` GET dédiée,
- un full-page reload,
- un composant maison de modale (le gem fournit `dsfr_modal` et le projet a déjà un pattern turbo-frame plus avancé).

Route inchangée (pas de member route). À la place, on ajoute une route qui sert le contenu HTML de la modale via turbo-frame :

```ruby
resources :user_rights, only: %i[index new create edit update destroy], path: 'gestion-des-droits' do
  member { get :confirm_destroy, path: 'confirmer-suppression' }
end
```

Action contrôleur `#confirm_destroy` (rend le partial dans un turbo-frame, pas une page complète) :

```ruby
def confirm_destroy
  @user = User.find(params[:id])
  authorize [:instruction, :user_right], :destroy?
  render partial: 'confirm_destroy', layout: false
end
```

Partial `app/views/instruction/user_rights/_confirm_destroy.html.erb` (contenu de la modale) :

- `h1#fr-modal-title-main-modal` « Supprimer tous les droits de %{email} ? »
- Paragraphe listant les rôles qui vont être retirés (ceux dans le périmètre du manager).
- Deux boutons : « Annuler » (ferme la modale via `aria-controls`) + `button_to t('.submit'), instruction_user_right_path(@user), method: :delete, class: 'fr-btn fr-btn--primary'`.

### 4.3 Entrées d’action

- Depuis la liste (icône corbeille) et la page edit (bouton « Supprimer l’utilisateur ») : on utilise `dsfr_main_modal_button(t('...'), confirm_destroy_instruction_user_right_path(user), class: 'fr-btn fr-btn--tertiary-no-outline fr-icon-delete-line')`. Ce helper ouvre la modale partagée et déclenche le chargement via turbo-frame.
- Dans le layout de la page, s’assurer que `<%= render 'shared/modal', id: 'main-modal' %>` est présent (c’est déjà le cas à plusieurs endroits, sinon l’ajouter dans le layout instruction ou dans l’index).
- Masquer les deux points d’entrée quand `user == current_user`.

### 4.4 i18n

```yaml
instruction:
  user_rights:
    confirm_destroy:
      title: "Supprimer tous les droits de %{email} ?"
      warning: "Cette action retirera les rôles suivants :"
      cancel: "Annuler"
      submit: "Supprimer tous les droits de l’utilisateur"
    destroy:
      success: "Tous les droits de %{email} ont été supprimés"
```

### 4.5 Feature cucumber

`features/instruction/gestion_des_droits/je_supprime_tous_les_droits.feature` :

```gherkin
# language: fr
Fonctionnalité: Espace instruction — supprimer tous les droits d'un utilisateur

  Contexte:
    Sachant que je suis un manager pour "API Entreprise"
    Et que je me connecte

  Scénario: Je supprime tous les droits d'un utilisateur
    Quand il y a l'utilisateur "eva@gouv.fr" avec le rôle "Reporter" pour "API Entreprise"
    Et que je me rends sur la "Gestion des droits"
    Et que je clique sur "Supprimer tous les droits de eva@gouv.fr"
    Alors la page contient "Supprimer tous les droits de eva@gouv.fr ?"
    Quand je clique sur "Supprimer tous les droits de l’utilisateur"
    Alors il y a un message de succès contenant "ont été supprimés"
    Et la page ne contient pas "eva@gouv.fr"

  Scénario: Les droits hors de mon périmètre ne sont pas supprimés
    Quand il y a l'utilisateur "mixte@gouv.fr" avec les rôles "api_entreprise:reporter,api_particulier:reporter"
    Et que je me rends sur la "Gestion des droits"
    Et que je clique sur "Supprimer tous les droits de mixte@gouv.fr"
    Et que je clique sur "Supprimer tous les droits de l’utilisateur"
    Alors l'utilisateur "mixte@gouv.fr" a le rôle "api_particulier:reporter"
    Et l'utilisateur "mixte@gouv.fr" n'a pas le rôle "api_entreprise:reporter"

  Scénario: Je ne peux pas me supprimer moi-même
    Quand je me rends sur la "Gestion des droits"
    Alors le bouton "Supprimer tous les droits de <mon email>" n'est pas visible
    Et l'accès direct à "/instruction/gestion-des-droits/<mon id>/confirmer-suppression" me redirige
```

### 4.6 Critères de recette étape 4

- [ ] Specs policy (cas `user == current_user`).
- [ ] Specs interactor (les rôles hors périmètre sont préservés).
- [ ] Cucumber vert.
- [ ] Revue accessibilité : page de confirmation lisible à l’écran lecteur (h1 explicite, description du résultat, bouton principal « Supprimer » en danger rouge `fr-btn--secondary`/`fr-btn--tertiary` selon DSFR pattern destructif).

---

## Transverses — à valider en fin de chaque étape

### Accessibilité (RGAA)

- Tous les champs ont un `<label>` associé explicite (pas de `placeholder` en guise de label).
- Les messages d’erreur utilisent `fr-messages-group` et sont reliés au champ via `aria-describedby`.
- Les badges de rôles ne reposent pas que sur la couleur : le texte du rôle est lu par un screen reader (contenu textuel + couleur).
- Les icônes seules (crayon / corbeille) possèdent un `aria-label` contextualisé.
- Le tableau utilise `<th scope="col">` pour les en-têtes.
- La navigation clavier fonctionne sur : bouton ajout, recherche, modifier, supprimer, modale/page de confirmation.
- Axe-core : 0 violation bloquante sur chaque vue.

### Tracking / Audit

- Chaque mutation crée un `AdminEvent` via `Admin::TrackEvent` avec `admin_event_name: 'user_rights_changed_by_manager'`. Assure la traçabilité symétrique à l’outil admin.
- `Admin::NotifyAdminsForRolesUpdate` envoie le mail aux admins comme pour l’outil admin.

### Tests manuels finaux (session intégrée)

- Parcours complet : un manager qui ajoute un nouveau manager (qui n’est pas admin) sur API Entreprise, puis le modifie, puis le supprime.
- Tentative d’injection d’un rôle admin via payload forgé → refus 422.
- Tentative d’édition d’un user hors périmètre via URL forgée → redirection.
- Test cross-worktree si d’autres devs sont sur des branches voisines (base `.env.local`).

---

## Audit RGAA — Étape 1 (liste des droits)

Audit effectué sur les fichiers de l’étape 1 : `app/views/instruction/user_rights/index.html.erb`, `app/helpers/instruction/user_rights_helper.rb`, `app/components/instructor_menu_component.{rb,html.erb}`, `app/views/layouts/header/_menu.html.erb`, `app/assets/stylesheets/dsfr-extensions.css`.

Périmètre vérifié : structure sémantique, landmarks, navigation clavier, labels, contrastes (palette DSFR), target size, zoom/reflow, badges, skip links, tableau de données.

### À corriger dans cette étape

1. **Tableau — ligne sans `<th scope="row">` (RGAA 5.7 · WCAG 1.3.1)**
   Chaque ligne identifie un utilisateur (son email). La cellule `<td class="user-email">` devrait être un `<th scope="row">` pour qu’un lecteur d’écran associe les autres cellules à l’identifiant de ligne.
   - Fichier : `app/views/instruction/user_rights/index.html.erb:54`
   - Correctif : remplacer `<td class="user-email">` par `<th scope="row" class="user-email">`.

2. **Boutons d’action icon-only — `<a>` / `<button>` avec contenu vide (RGAA 7.1 · WCAG 2.5.3 Label in Name)**
   Les boutons « modifier » et « supprimer » utilisent `link_to … do; end` avec un bloc vide : seule l’icône (`fr-icon-edit-line` / `fr-icon-delete-line`) est rendue, en `::before` via CSS. Le nom accessible est porté uniquement par `aria-label` (et dupliqué dans `title`). Plus robuste : ajouter un libellé visible pour lecteur d’écran.
   - Fichier : `app/views/instruction/user_rights/index.html.erb:68-79`
   - Correctif :
     ```erb
     <%= link_to edit_instruction_user_right_path(user),
         class: 'fr-btn fr-btn--tertiary-no-outline fr-btn--sm fr-icon-edit-line' do %>
       <span class="fr-sr-only"><%= t('...edit_aria', email: user.email) %></span>
     <% end %>
     ```
     Retirer `title:` et `aria: { label: }` puisque le `<span class="fr-sr-only">` porte désormais le nom accessible (et reste synchronisé avec le libellé lu à haute voix).

3. **Colonne Actions — pas de regroupement `fr-btns-group` (RGAA 10.7 · WCAG 2.5.8 Target Size)**
   Les deux actions (link_to + button_to) sont rendues côte à côte sans espacement contrôlé. DSFR prévoit `fr-btns-group fr-btns-group--inline-sm` pour garantir un gap horizontal et éviter les cliques erronés entre cibles adjacentes.
   - Fichier : `app/views/instruction/user_rights/index.html.erb:67-80`
   - Correctif : envelopper les deux actions dans `<ul class="fr-btns-group fr-btns-group--inline-sm fr-btns-group--sm">` avec un `<li>` par action (forme DSFR idiomatique).

4. **Caption du tableau — contexte enrichi (RGAA 5.4)**
   La légende se limite au titre de page. Ajouter le nombre d’utilisateurs (ou le périmètre des définitions managées) en `fr-sr-only` aide les utilisateurs de lecteur d’écran.
   - Fichier : `app/views/instruction/user_rights/index.html.erb:33`
   - Correctif suggéré :
     ```erb
     <caption class="fr-sr-only">
       <%= t('.title') %> — <%= t('.users_count', count: @users.size) %>
     </caption>
     ```

5. **Confirmation de suppression — `window.confirm` natif**
   `data-turbo-confirm` produit une confirmation navigateur native. Accessible au clavier mais hors charte DSFR. Pas bloquant pour l’étape 1 puisque l’étape 4 prévoit une modale DSFR dédiée ; à supprimer lors du déploiement de la modale (suppression fine : la liste ne doit plus exposer le bouton `delete` direct, seule la modale le portera).

### À noter (constat sans correction bloquante dans cette étape)

- **Skip link « Aller au contenu » absent de la page** (RGAA 12.7). La page surcharge `content_for :skip_links` uniquement avec Menu + Pied de page, perdant ainsi le lien d’évitement par défaut `Aller au contenu`. **Constat projet** : la même convention est appliquée sur `developers/oauth_applications`, `instruction/message_templates`, `user/organizations`, `profile/edit`, etc. À traiter globalement (hors périmètre DP-1684) — ouvrir un ticket dédié ou proposer un concern `default_skip_links_with_menu_footer`.
- **Boutons d’édition identiques répétés N fois par utilisateur** (un `<tr>` par couple user × définition depuis l’abandon du `rowspan`). Le nom accessible reste correct (il pointe vers une action « tous droits de l’utilisateur »). Non bloquant.
- **Badges — palette DSFR validée** (`purple-glycine`, `pink-tuile`, `yellow-tournesol`, `blue-ecume`). Contrastes conformes par construction (tokens DSFR). Le texte du rôle est porté textuellement (pas seulement par la couleur). ✅
- **Override CSS `.fr-badge--role::before { content: none; }`** : neutralise l’icône recyclage ajoutée globalement sur `fr-badge--purple-glycine`. Pas d’impact a11y (pseudo-element hors arbre d’accessibilité). ✅
- **Menu instructeur** : le `<li class="fr-nav__item">` ajouté s’insère dans le `<nav aria-label="Menu principal">` existant. Rien à corriger côté menu. ✅
- **Empty state** : statique à l’affichage initial — pas de `role="status"` requis. ✅
- **Target size `fr-btn--sm`** : 32×32 dans DSFR, ≥ seuil WCAG 2.5.8 de 24×24. À re-vérifier visuellement une fois le correctif n°3 appliqué (le regroupement `fr-btns-group` peut modifier la surface cliquable). 

### À prévoir pour les étapes suivantes

- **Étape 2 (formulaire add)** : labels explicites sur chaque champ (`<label for>` ou `DSFRFormBuilder`), `aria-describedby` vers les `fr-error-text`, `aria-required="true"` sur les champs obligatoires, focus sur le premier champ en erreur à la soumission, `fr-callout` accessible (titre `<h2>` / `<h3>` selon hiérarchie), Stimulus pour l’ajout/suppression dynamique de lignes « Portée / Rôle » qui annonce les changements via `role="status"` `aria-live="polite"`.
- **Étape 3 (edit)** : mêmes contraintes que l’étape 2 ; attention au focus management après suppression d’une ligne (déplacer le focus sur la ligne suivante ou sur le bouton « Ajouter un droit »).
- **Étape 4 (delete)** : modale DSFR (`dsfr_modal`) avec `aria-labelledby`, focus piégé, retour du focus sur le déclencheur à la fermeture, `Escape` pour annuler.

---

## Synthèse des fichiers à créer / modifier

| Étape | Fichier | Type |
|------|---------|------|
| 1 | `app/models/user.rb` | edit (scope + helpers) |
| 1 | `spec/models/user_spec.rb` | edit |
| 1 | `app/policies/instruction/user_right_policy.rb` | create |
| 1 | `spec/policies/instruction/user_right_policy_spec.rb` | create |
| 1 | `config/routes.rb` | edit (resources user_rights) |
| 1 | `app/controllers/instruction/user_rights_controller.rb` | create |
| 1 | `app/views/instruction/user_rights/index.html.erb` | create |
| 1 | `app/helpers/instruction/user_rights_helper.rb` (helper `role_badge`) | create |
| 1 | `spec/helpers/instruction/user_rights_helper_spec.rb` | create |
| 1 | `app/components/instructor_menu_component.{rb,html.erb}` | edit |
| 1 | `app/views/layouts/header/_menu.html.erb` | edit |
| 1 | `config/locales/{instruction,page_titles}.fr.yml` | edit |
| 1 | `features/instruction/gestion_des_droits/je_vois_la_liste_des_droits.feature` | create |
| 2 | `app/forms/instruction/user_right_form.rb` | create |
| 2 | `spec/forms/instruction/user_right_form_spec.rb` | create |
| 2 | `app/interactors/instruction/merge_managed_roles.rb` | create |
| 2 | `spec/interactors/instruction/merge_managed_roles_spec.rb` | create |
| 2 | `app/organizers/instruction/update_user_rights.rb` | create |
| 2 | `spec/organizers/instruction/update_user_rights_spec.rb` | create |
| 2 | `app/controllers/instruction/user_rights_controller.rb` | edit (new/create) |
| 2 | `app/views/instruction/user_rights/new.html.erb` + `_form.html.erb` + `_right_field.html.erb` | create |
| 2 | `app/components/instruction/user_rights/right_field_component.{rb,html.erb}` | create |
| 2 | `spec/components/previews/instruction/user_rights/right_field_component_preview.rb` | create |
| 2 | `app/javascript/controllers/user_rights_form_controller.js` | create |
| 2 | `features/instruction/gestion_des_droits/j_ajoute_des_droits.feature` | create |
| 3 | `app/controllers/instruction/user_rights_controller.rb` | edit (edit/update) |
| 3 | `app/views/instruction/user_rights/edit.html.erb` | create |
| 3 | `app/forms/instruction/user_right_form.rb` | edit (auto-suppression) |
| 3 | `features/instruction/gestion_des_droits/je_modifie_des_droits.feature` | create |
| 4 | `app/controllers/instruction/user_rights_controller.rb` | edit (destroy + confirm_destroy) |
| 4 | `app/views/instruction/user_rights/_confirm_destroy.html.erb` (partial rendu dans turbo-frame) | create |
| 4 | `config/routes.rb` | edit (member confirm_destroy) |
| 4 | `features/instruction/gestion_des_droits/je_supprime_tous_les_droits.feature` | create |

---

## Décisions de revue (intégrées dans le plan)

1. **Ordre de merge** : l’utilisateur gère lui-même le découpage en PR selon la complexité rencontrée.
2. **Manager self** : **le manager n’apparaît pas dans sa propre liste** → filtrage dans le contrôleur `index` + policy `edit?/destroy?` qui refuse `record == user`.
3. **Rôle `developer`** : **non proposé** dans l’interface instruction (les admins s’en occupent). Les rôles sélectionnables sont `reporter`, `instructor`, `manager`.
4. **Recherche** : **skippée dans cette itération**. Pas de `params[:q]`, pas de `dsfr_search`, pas de scénario cucumber dédié.
5. **Notifications** : seuls les admins sont notifiés (via `Admin::NotifyAdminsForRolesUpdate`). Pas de notification à l’utilisateur cible.

## TODO
- [ ] Affichage de l'aide contextuelle sur les niveaux des roles, voir la maquette ici : https://raw.githubusercontent.com/etalab/data_pass/e10b75cb856ef6b1c8a6bb184bbc0c1c16d913f9/docs/shaping/dp-1572%20-%20Gestion%20des%20droits%20d'instruction%20par%20les%20FD/dp-1613-wireframes.svg . Utiliser ce contenu, l'aide doit être cachée par défaut et visible en cliquant sur un lien d'aide avec icone. Vérifier comment faire ça de manière accessible avec un composant DSFR.
- [ ] Affichage des droits non modifiables : peut-on les afficher dans le formulaire avec des champs disabled ou est-ce que ça pose un problème d'accessiblité ?
- [ ] Il faut grouper les droits par utilisateur, c'est illisible actuellement. Dans un premier temps mettre le FD en ligne avec les roles, avec "(Tous)" à côté du FD dans le cas des wildcard et à la ligne pour chaque FD. 
- [ ] L'email de l'utilisateur ne doit pas être présent dans le formulaire de modification
