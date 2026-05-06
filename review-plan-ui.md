# Review plan — DP-1684 (UI gestion des droits utilisateur)

Points relevés à la relecture des 4 fichiers cœur, classés par impact
sur la lisibilité. Les items 🔴 sont détaillés avec problème, solution,
impact et points à vérifier. Les 🟡🟢 restent en résumé.

---

## Form object — `app/forms/instruction/user_right_form.rb`

### 🔴 5 validateurs séparés sur `rights`

#### Problème

```ruby
# L13-17
validate :at_least_one_right
validate :rights_are_complete
validate :no_admin_role
validate :role_types_are_allowed
validate :rights_scoped_to_manager_authority
```

Chaque validateur est une méthode privée séparée (L77-114, 38 L), avec
des patterns similaires (`rights.each … break` ou `rights.any? …`). Un
reviewer doit :
- suivre 5 méthodes pour reconstituer le contrat de validation,
- repérer que 3 d'entre elles ajoutent des erreurs sur `:rights`, une
  sur `:base`, une sur `:email`,
- garder en tête que certains validateurs s'excluent mutuellement
  (`no_admin_role` vs `role_types_are_allowed`).

#### Solution proposée : extraire un `RightValidator` PORO

```ruby
# app/models/instruction/right_validator.rb
class Instruction::RightValidator
  def initialize(rights, permissions)
    @rights = rights
    @permissions = permissions
  end

  def validate
    return [[:base, :at_least_one_right]] if no_right_filled?
    return [[:rights, :incomplete_right]] if partially_filled?

    @rights.flat_map { |right| error_codes_for(right) }.compact
  end

  private

  def no_right_filled?
    @rights.none? { |r| r[:scope].present? || r[:role_type].present? }
  end

  def partially_filled?
    @rights.any? { |r| r[:scope].blank? || r[:role_type].blank? }
  end

  def error_codes_for(right)
    [
      (role_type_error(right) if right[:role_type].present?),
      (scope_error(right)     if right[:scope].present?)
    ]
  end

  def role_type_error(right)
    return if @permissions.allowed_role_types.include?(right[:role_type])

    [:rights, :role_type_not_allowed]
  end

  def scope_error(right)
    return if @permissions.authorized_scopes.include?(right[:scope])

    [:rights, :scope_not_authorized]
  end
end
```

Dans le form :

```ruby
validate :rights_are_valid

private

def rights_are_valid
  Instruction::RightValidator
    .new(rights, permissions)
    .validate
    .each { |attr, code| errors.add(attr, code) }
end
```

#### Impact

- Form : −38 lignes de méthodes privées, le contrat de validation se
  lit en 15 L du PORO dans l'ordre logique (présence → complétude →
  valeurs autorisées).
- PORO testable en isolation avec des rights + permissions de test,
  pas besoin de monter un form complet.
- S'aligne sur la refacto `Authority` : le validateur prend une
  interface abstraite (`authorized_scopes`, `allowed_role_types`),
  donc marche avec `ManagerAuthority` ou `AdminAuthority` sans
  changement.

#### À vérifier

- Comportement de `break` actuel : les validateurs
  `role_types_are_allowed` et `rights_scoped_to_manager_authority`
  `break` au premier échec → une seule erreur par catégorie. Le PORO
  proposé ajoute une erreur par right invalide : **changement de
  comportement** sur l'affichage (plus d'erreurs affichées si
  plusieurs rights fautifs). Décider si c'est souhaité ou garder le
  `break` (meilleur pour l'UX : un message par type d'erreur).
- Les specs actuelles (`spec/forms/instruction/user_right_form_spec.rb`)
  devraient continuer à passer, mais relire les assertions
  `hash_including(error: :X)` qui utilisent `contain_exactly` ou
  `include`.

---

### 🔴 `no_admin_role` redondant avec `role_types_are_allowed`

#### Problème

```ruby
ALLOWED_ROLE_TYPES = %w[reporter instructor manager].freeze  # pas d'admin

def no_admin_role
  return unless rights.any? { |r| r[:role_type] == 'admin' }
  errors.add(:rights, :admin_role_forbidden)
end

def role_types_are_allowed
  rights.each do |r|
    next if r[:role_type].blank? || r[:role_type] == 'admin'  # <-- exception
    next if ALLOWED_ROLE_TYPES.include?(r[:role_type])
    errors.add(:rights, :role_type_not_allowed)
    break
  end
end
```

`admin` n'est pas dans `ALLOWED_ROLE_TYPES`, donc
`role_types_are_allowed` le refuserait naturellement. La seule raison
d'être du check explicite `r[:role_type] == 'admin'` dans
`role_types_are_allowed` (L98), c'est d'éviter de signaler 2 erreurs
pour la même cause. Autrement dit, `no_admin_role` existe uniquement
pour émettre un message différent — sauf qu'un reviewer qui arrive
sur le fichier voit deux règles apparemment distinctes.

#### Solution

Supprimer `no_admin_role` + la clé i18n `admin_role_forbidden`.
Supprimer le `|| r[:role_type] == 'admin'` dans
`role_types_are_allowed`.

Si le PORO `RightValidator` est introduit en parallèle (item
précédent), admin est implicitement couvert par `allowed_role_types`.

#### Impact

- −10 lignes (méthode + appel `validate` + clé i18n).
- Une règle en moins à tracer pour le reviewer.
- Message d'erreur unifié : « Type de rôle non autorisé » couvre
  `admin` comme n'importe quel rôle interdit (ex. `developer` pour
  un manager).

#### À vérifier

- Le message actuel pour admin est « Le rôle administrateur est
  interdit » (clé `admin_role_forbidden`). Après suppression, admin
  affichera « Type de rôle non autorisé » comme les autres. Si le
  message explicite « admin interdit » est utile côté UX
  (particulièrement pour l'usage en console où un dev pourrait
  essayer), garder le validateur spécifique — sinon supprimer.
- Les features cucumber qui testent le cas admin (chercher
  `admin_role_forbidden` ou scénario « un manager ne peut pas
  donner le rôle admin ») à ajuster.

---

### 🟡 `ALLOWED_ROLE_TYPES` accessible par 3 chemins

Choisir `permissions.allowed_role_types` partout. Virer l'alias L5.

### 🟡 `rights=` défensif

Le controller normalise déjà (`params.expect(...).to_h.symbolize_keys`).
Simplifier à `Array(raw).map { |entry| normalize_right(entry) }.uniq`
sauf si un chemin d'appel différent est confirmé.

### 🟡 `organizer_failed?` couple form et controller

Remplacer par `save_for` qui retourne un symbole ou par
`errors.add(:base, :save_failed)`.

### 🟢 `actor:` dans `save_for` duplique `@manager`

Retirer le paramètre.

---

## Controller — `app/controllers/instruction/user_rights_controller.rb`

### 🔴 `form_params` et `update_form_params` quasi-identiques

#### Problème

```ruby
# L77-82
def form_params
  params
    .expect(instruction_user_right_form: [:email, { rights: [%i[scope role_type]] }])
    .to_h
    .symbolize_keys
end

# L84-89
def update_form_params
  params
    .expect(instruction_user_right_form: [{ rights: [%i[scope role_type]] }])
    .to_h
    .symbolize_keys
end
```

Deux méthodes qui ne diffèrent que par la présence de `:email`. La
duplication littérale force le reviewer à comparer caractère par
caractère pour repérer la seule vraie différence. Et ça ouvre la porte
à une drift silencieuse si quelqu'un ajoute un champ à l'une sans
l'autre.

#### Solution proposée

Une seule méthode avec `except(:email)` sur l'appel update :

```ruby
def create
  @form = Instruction::UserRightForm.new(manager: current_user, **form_params)
  # ...
end

def update
  @form = Instruction::UserRightForm.new(
    manager: current_user,
    user: @target_user,
    **form_params.except(:email)
  )
  # ...
end

private

def form_params
  params
    .expect(instruction_user_right_form: [:email, { rights: [%i[scope role_type]] }])
    .to_h
    .symbolize_keys
end
```

Alternative plus explicite : un paramètre `allow_email:` :

```ruby
def form_params(allow_email: true)
  permitted = allow_email ? [:email, { rights: [...] }] : [{ rights: [...] }]
  params.expect(instruction_user_right_form: permitted).to_h.symbolize_keys
end
```

Je penche pour la première : un seul permit officiel, `update` écarte
manuellement le champ qu'il ne veut pas. Sécurité : `email` vient du
form params, il ne peut pas écraser `@target_user.email` puisqu'il est
filtré en amont de `UserRightForm.new`.

#### Impact

- −10 lignes.
- Une seule définition du schéma des params du form.
- Pas de risque de divergence silencieuse.

#### À vérifier

- Le form avec `email: "..."` en update : le form actuel a
  `validates :email, ..., if: :email_required?` et `email_required?`
  renvoie `false` quand `user` est présent. Donc même si `email`
  passe, il est ignoré côté validation. Mais **il est quand même
  assigné comme attribut** — vérifier qu'aucune route d'édition ne
  l'utilise en aval (ex. notifications). En pratique le form utilise
  `email` uniquement dans `create` pour le lookup.

---

## `_form.html.erb`

### 🔴 3 blocs display longs à extraire

#### Problème

Le fichier fait 109 L dont ~49 L sont des blocs d'affichage qui
encombrent la lecture de la structure du form :

- **L12-21 (10 L)** — bloc d'erreurs : alerte DSFR avec liste
  `form.errors.full_messages`.
- **L32-50 (19 L)** — accordéon d'aide : `<section>` DSFR avec un
  `<dl>/<dt>/<dd>` iterant sur les 3 rôles.
- **L52-65 (14 L)** — liste des droits readonly : condition + panneau
  + `<ul>` avec `scope_label` + `role_badge`.

Résultat : la structure « identity card → section droits → boutons »
est noyée dans 49 L de rendu conditionnel / itératif.

#### Solution proposée

Vérification faite des composants `dsfr-view-components` 4.1.3
déjà disponibles :
- ✅ `dsfr_alert(type: :error, title:)` — utilisé dans `stats/index`
- ✅ `dsfr_accordion(title, id:)` — utilisé dans `faq` et
  `message_templates/index`
- ❌ pas de composant table (voir item `index.html.erb`)

**1. Bloc d'erreurs : `dsfr_alert`, pas de composant spécifique**

```erb
<% if form.errors.any? %>
  <%= dsfr_alert type: :error,
                 title: t('errors.messages.form_errors', count: form.errors.count),
                 html_attributes: { class: 'fr-mb-4w' } do %>
    <ul class="fr-messages-group">
      <% form.errors.full_messages.each do |message| %>
        <li class="fr-message fr-message--error"><%= message %></li>
      <% end %>
    </ul>
  <% end %>
<% end %>
```

Gain modeste (−2 L) mais aligne sur le pattern existant du projet,
on profite des évolutions de la gem.

**2. Accordéon d'aide : `dsfr_accordion` + partial de contenu**

Le helper gère toute la structure sémantique et ARIA. Le contenu
spécifique part dans un partial.

```erb
<%= dsfr_accordion t('instruction.user_rights.new.roles_help.title'),
                   id: 'user-rights-roles-help',
                   html_attributes: { class: 'fr-mb-3w' } do %>
  <%= render 'roles_help' %>
<% end %>
```

```erb
<%# app/views/instruction/user_rights/_roles_help.html.erb %>
<h4 class="fr-h6 fr-mb-1w"><%= t('instruction.user_rights.new.roles_help.scope_section') %></h4>
<p class="fr-mb-3w"><%= t('instruction.user_rights.new.roles_help.scope_description') %></p>

<h4 class="fr-h6 fr-mb-1w"><%= t('instruction.user_rights.new.roles_help.roles_section') %></h4>
<dl class="fr-mb-0">
  <% %w[reporter instructor manager].each do |role_type| %>
    <dt class="fr-text--bold"><%= t("instruction.user_rights.roles.#{role_type}") %></dt>
    <dd class="fr-ml-0 fr-mb-2w"><%= t("instruction.user_rights.new.roles_help.#{role_type}") %></dd>
  <% end %>
</dl>
```

**Pourquoi partial plutôt qu'un composant dédié** : le contenu est
statique, non réutilisé, sans logique. Un composant réimplémenterait
la structure DSFR de l'accordéon (alors que le helper l'encapsule
déjà), uniquement pour encapsuler du contenu. Un partial suffit et
s'aligne avec l'usage existant dans `faq.html.erb` (qui accumule des
blocs similaires).

**Si un jour on a plusieurs « help accordions » dans l'app** — à ce
moment créer un composant générique `HelpAccordionComponent` qui
accepte `title:` + `content` + éventuellement une liste de sections.
Pour l'instant YAGNI.

**3. `Molecules::Instruction::UserRights::ReadonlyRightsListComponent`**

```ruby
class Molecules::Instruction::UserRights::ReadonlyRightsListComponent < ApplicationComponent
  def initialize(rights:)
    @rights = rights
  end

  def render?
    @rights.any?
  end

  private

  attr_reader :rights
end
```

```erb
<div class="fr-mb-3w fr-p-3w user-rights-form__readonly" id="readonly-rights">
  <h3 class="fr-h6 fr-mb-1w"><%= t('instruction.user_rights.edit.readonly_section') %></h3>
  <p class="fr-hint-text fr-mb-2w"><%= t('instruction.user_rights.edit.readonly_hint') %></p>
  <ul role="list" class="fr-mb-0 user-rights-form__readonly-list">
    <% rights.each do |right| %>
      <li class="fr-mb-1w">
        <strong><%= helpers.scope_label(right[:scope]) %></strong>
        <%= helpers.role_badge(right[:role_type]) %>
      </li>
    <% end %>
  </ul>
</div>
```

**`_form.html.erb` après extraction** (environ 60 L) :

```erb
<%= form_with model: form, url: url, method: method,
              scope: :instruction_user_right_form,
              builder: DsfrFormBuilder,
              data: { ... } do |f| %>

  <% if form.errors.any? %>
    <%= dsfr_alert type: :error,
                   title: t('errors.messages.form_errors', count: form.errors.count),
                   html_attributes: { class: 'fr-mb-4w' } do %>
      <ul class="fr-messages-group">
        <% form.errors.full_messages.each do |message| %>
          <li class="fr-message fr-message--error"><%= message %></li>
        <% end %>
      </ul>
    <% end %>
  <% end %>

  <%= render 'identity_card',
             form_builder: show_email_field ? f : nil,
             target_user: target_user %>

  <section class="fr-mb-3w fr-p-3w user-rights-card" aria-labelledby="user-rights-rights-section">
    <h2 id="user-rights-rights-section" class="fr-h5 user-rights-card__title">
      <%= t('instruction.user_rights.new.rights_section') %>
    </h2>

    <%= dsfr_accordion t('instruction.user_rights.new.roles_help.title'),
                       id: 'user-rights-roles-help',
                       html_attributes: { class: 'fr-mb-3w' } do %>
      <%= render 'roles_help' %>
    <% end %>

    <%= render Molecules::Instruction::UserRights::ReadonlyRightsListComponent.new(rights: readonly_rights) %>

    <%# fields + template Stimulus (inchangé, ~19 L) %>
    <div data-user-rights-form-target="fields">
      <% form.rights.each_with_index do |right, index| %>
        <%= render Molecules::Instruction::UserRights::RightFieldComponent.new(
              index: index, scope: right[:scope], role_type: right[:role_type], permissions: permissions) %>
      <% end %>
    </div>
    <template data-user-rights-form-target="template">
      <%= render Molecules::Instruction::UserRights::RightFieldComponent.new(
            index: '__INDEX__', scope: '', role_type: '', permissions: permissions) %>
    </template>

    <%# add button + sr-only announcement (inchangé) %>
  </section>

  <%# footer buttons (inchangé) %>
<% end %>
```

#### Impact

- `_form.html.erb` : 109 → ~60 L. Structure logique lisible d'un
  coup d'œil.
- 3 composants prévisualisables et testables indépendamment (ajouter
  un `_preview.rb` pour chacun dans `spec/components/previews/`).
- `FormErrorsComponent` réutilisable dans tous les formulaires du
  projet.
- Déverrouille la review des items "cœur" : le reviewer peut
  parcourir `_form.html.erb` en 30 s.

#### À vérifier

- Convention de namespacing du projet : pas d'`atoms/`, donc tout
  sous `molecules/` même pour `FormErrorsComponent`. À confirmer
  avec Étienne si un pattern existe.
- Les ID DOM (`readonly-rights`, `user-rights-roles-help`) sont
  référencés par `aria-controls` ou par les features cucumber
  (`readonly-rights` apparaît dans `je_modifie_des_droits.feature`
  probablement). Préserver les mêmes valeurs dans les templates
  des composants.
- Appel à `helpers.scope_label` et `helpers.role_badge` depuis un
  composant : vérifier que `ApplicationComponent` expose bien les
  helpers, ou instancier le helper manuellement.

---

## `index.html.erb`

### 🔴 52 L de tableau inline (L32-83)

#### Problème

Le template fait 88 L dont 52 pour un seul tableau : `<caption>`,
`<thead>` avec itération sur les headers, `<tbody>` avec `@users.each`
et, pour chaque user, 5 cellules dont 2 qui contiennent elles-mêmes
une liste (droits groupés) ou un groupe de boutons (actions).

Cette profondeur rend la structure du tableau difficile à suivre et
impossible à tester autrement qu'à travers un feature complet.

#### Solution proposée

La gem `dsfr-view-components` ne fournit pas de `TableComponent` —
volontairement, parce qu'un tableau est trop contextuel (colonnes,
tri, actions, groupement). DSFR ne fournit que des classes CSS
(`fr-table`, `fr-table--bordered`). Donc création d'un composant
**local au domaine DP-1684**, pas de PR à proposer à la gem.

Extraction en 2 composants (le tableau est un **organism**, la ligne
est une **molecule**).

**1. `Organisms::Instruction::UserRights::TableComponent`**

```ruby
class Organisms::Instruction::UserRights::TableComponent < ApplicationComponent
  HEADERS = %w[email family_name given_name rights actions].freeze

  def initialize(users:, actor:)
    @users = users
    @actor = actor
  end

  private

  attr_reader :users, :actor
end
```

```erb
<div class="fr-table fr-table--bordered">
  <div class="fr-table__container">
    <div class="fr-table__content">
      <table id="user-rights-table">
        <caption class="fr-sr-only">
          <%= t('instruction.user_rights.index.title') %> —
          <%= t('instruction.user_rights.index.users_count', count: users.size) %>
        </caption>
        <thead>
          <tr>
            <% HEADERS.each do |header| %>
              <th scope="col"><%= t("instruction.user_rights.index.table.header.#{header}") %></th>
            <% end %>
          </tr>
        </thead>
        <tbody>
          <% users.each do |user| %>
            <%= render Molecules::Instruction::UserRights::TableRowComponent.new(user: user, actor: actor) %>
          <% end %>
        </tbody>
      </table>
    </div>
  </div>
</div>
```

**2. `Molecules::Instruction::UserRights::TableRowComponent`**

```ruby
class Molecules::Instruction::UserRights::TableRowComponent < ApplicationComponent
  def initialize(user:, actor:)
    @user = user
    @actor = actor
  end

  private

  attr_reader :user, :actor

  def visible_rights
    helpers.visible_rights_for(user, actor)
  end
end
```

```erb
<tr class="user" id="<%= dom_id(user) %>">
  <th scope="row" class="user-email"><%= user.email %></th>
  <td class="user-family-name"><%= user.family_name %></td>
  <td class="user-given-name"><%= user.given_name %></td>
  <td class="user-rights">
    <ul role="list" class="user-rights-list fr-mb-0">
      <% visible_rights.each do |entry| %>
        <li class="user-rights-list__item">
          <span class="user-rights-list__scope"><%= entry[:label] %></span>
          <% entry[:role_types].each do |role_type| %>
            <%= helpers.role_badge(role_type) %>
          <% end %>
        </li>
      <% end %>
    </ul>
  </td>
  <td class="user-actions">
    <ul class="fr-btns-group fr-btns-group--inline-sm fr-btns-group--sm user-actions__group">
      <li>
        <%= link_to edit_instruction_user_right_path(user),
              class: 'fr-btn fr-btn--tertiary-no-outline fr-btn--sm fr-icon-edit-line',
              title: t('instruction.user_rights.index.table.edit_aria', email: user.email),
              aria: { label: t('instruction.user_rights.index.table.edit_aria', email: user.email) } do %>
        <% end %>
      </li>
      <li>
        <%= dsfr_main_modal_button '',
              confirm_destroy_instruction_user_right_path(user),
              class: 'fr-btn fr-btn--tertiary-no-outline fr-btn--sm fr-icon-delete-line',
              title: t('instruction.user_rights.index.table.destroy_aria', email: user.email),
              'aria-label': t('instruction.user_rights.index.table.destroy_aria', email: user.email) %>
      </li>
    </ul>
  </td>
</tr>
```

**`index.html.erb` après extraction** (~30 L) :

```erb
<% set_title! t('page_titles.instruction_user_rights') %>

<% content_for :skip_links do %>
  <%= skip_link(t('.skip_links.menu'), 'header') %>
  <%= skip_link(t('.skip_links.footer'), 'footer') %>
<% end %>

<div class="fr-container fr-my-5w">
  <div class="fr-grid-row fr-grid-row--gutters fr-grid-row--middle fr-mb-4w">
    <div class="fr-col">
      <h1 class="fr-mb-0"><%= t('instruction.user_rights.index.title') %></h1>
    </div>
    <div class="fr-col-auto">
      <%= link_to t('instruction.user_rights.index.add_cta'),
        new_instruction_user_right_path,
        class: 'fr-btn fr-btn--icon-left fr-icon-user-add-line',
        id: 'add-user-rights-button' %>
    </div>
  </div>

  <% if @users.empty? %>
    <div class="fr-py-6w fr-text--center" id="user-rights-empty-state">
      <p class="fr-text--lg fr-mb-4w"><%= t('instruction.user_rights.index.empty_state') %></p>
      <%= link_to t('instruction.user_rights.index.add_cta'),
        new_instruction_user_right_path,
        class: 'fr-btn fr-btn--icon-left fr-icon-user-add-line' %>
    </div>
  <% else %>
    <%= render Organisms::Instruction::UserRights::TableComponent.new(users: @users, actor: current_user) %>
  <% end %>
</div>
```

#### Impact

- `index.html.erb` : 88 → ~30 L. Structure page = header + empty state
  ou tableau.
- Row et table testables en isolation (specs composant +
  prévisualisation).
- Le pattern « tableau d'utilisateurs avec rôles » sera vraisemblablement
  repris côté admin → composants déjà en place.

#### À vérifier

- Les features cucumber s'appuient sur des sélecteurs comme
  `#user-rights-table`, `tr.user`, `.user-email`, `.user-actions`. Le
  composant doit préserver exactement les mêmes classes et IDs.
- Tests : `spec/components/organisms/instruction/user_rights/table_component_spec.rb`
  + `spec/components/molecules/.../table_row_component_spec.rb`
  + previews associées.

---

## Récapitulatif des priorités

### Avant la review (~1 h)

1. **Supprimer `no_admin_role`** (10 min) — une règle de validation
   en moins à tracer.
2. **Unifier `form_params` / `update_form_params`** (10 min) — une
   duplication visible en moins.
3. **Alléger `_form.html.erb`** (30 min) :
   - Bloc d'erreurs : remplacer le `<div class="fr-alert">` inline
     par `dsfr_alert(type: :error, ...)`.
   - Accordéon d'aide : remplacer le `<section class="fr-accordion">`
     inline par `dsfr_accordion(...) do render 'roles_help' end`,
     déplacer le `<dl>` dans `_roles_help.html.erb`.
   - Liste readonly : extraire en
     `Molecules::Instruction::UserRights::ReadonlyRightsListComponent`
     (vrai composant car contient de la logique d'affichage par
     `right`).

   `_form.html.erb` passe de 109 à ~60 L.

### Dans la PR follow-up (admin)

- **Extraire `RightValidator`** (aligné avec la refacto `Authority`).
- **Extraire `TableComponent` + `TableRowComponent`** pour l'index,
  réutilisés côté admin.
- **`save_for` absorbe le lookup email** → `create` en 3 lignes.
- **Harmoniser les clés i18n** `save.error` (partagée create/update).
- **Résoudre les 🟡** : simplifier `rights=`, supprimer
  `organizer_failed?`, retirer `actor:` de `save_for`.
