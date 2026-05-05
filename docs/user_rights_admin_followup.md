# Étendre `/gestion-des-droits` aux administrateurs

Suite à DP-1684 qui a livré l'UI `/instruction/gestion-des-droits` pour les
managers. Objectif : ouvrir la même interface aux admins, avec un périmètre
élargi (toutes les `AuthorizationDefinition`, tous les `DataProvider` au
niveau FD, rôle `developer` inclus), sans dupliquer le flow.

---

## État actuel (rappel rapide)

DP-1684 a déjà extrait les briques suivantes — la suite est essentiellement
un renommage et l'ajout d'une 2ᵉ implémentation :

- `Instruction::ManagerScopeOptions` (`app/models/instruction/`)
  expose `allowed_role_types`, `authorized_scopes`, `managed_definitions`,
  `fd_manager_for?` à partir d'un `manager`.
- `Instruction::UserRightsView` (`app/models/instruction/`)
  expose `modifiable` / `readonly` / `grouped_visible` pour un couple
  `(manager, user)`.
- `Instruction::RightValidator` consomme `permissions.allowed_role_types`
  et `permissions.authorized_scopes` (duck-typé).
- `Molecules::Instruction::UserRights::RightFieldComponent` reçoit déjà un
  `permissions:` polymorphe (pas pinned au manager).
- `Instruction::UpdateUserRights` orchestre `MergeManagedRoles` →
  `Admin::TrackEvent` → `Admin::NotifyAdminsForRolesUpdate`.
- `Instruction::UserRightsController` porte les 6 actions et la recherche
  utilisateurs (commit `dbbb7342`).

Les seules zones encore manager-only :

- Le keyword `manager:` dans le form, le controller, l'interactor et la view.
- `Instruction::UserRightPolicy#enabled?` qui teste `user.manager?`.
- `User#manages_role?` qui retourne `false` pour un admin (regarde
  `definition_ids_for(:manager)` + `managed_fd_slugs`).
- L'absence de pendant admin pour `Instruction::ManagerScopeOptions`.

---

## Décisions de design

### 1. Abstraction `Rights::Authority` (base + sous-classes)

Renommer/déplacer `Instruction::ManagerScopeOptions` vers `Rights::ManagerAuthority`
et créer `Rights::AdminAuthority`. Une base `Rights::Authority` documente le
contrat duck-typé attendu par le form, le validator, le component, la view.

```ruby
module Rights
  class Authority
    # Contract attendu par UserRightsForm, RightValidator, RightFieldComponent,
    # UserRightsView :
    #   - allowed_role_types        → Array<String>
    #   - authorized_scopes         → Array<String>  ("provider:def_id" / "provider:*")
    #   - managed_definitions       → ActiveRecord::Relation<AuthorizationDefinition>
    #   - fd_manager_for?(slug)     → Boolean
  end

  class ManagerAuthority < Authority
    ALLOWED_ROLE_TYPES = %w[reporter instructor manager].freeze
    # ... délègue à user.authorization_definition_roles_as(:manager) + managed_fd_slugs
  end

  class AdminAuthority < Authority
    ALLOWED_ROLE_TYPES = %w[reporter instructor manager developer].freeze

    def authorized_scopes
      definition_scopes + fd_scopes  # toutes définitions + tous providers en :*
    end

    def managed_definitions
      AuthorizationDefinition.all
    end

    def fd_manager_for?(_provider_slug)
      true  # admin = FD-manager implicite sur tous les providers
    end
  end
end
```

Le rôle `admin` n'est **pas** dans `AdminAuthority::ALLOWED_ROLE_TYPES` :
attribuer/révoquer le rôle admin reste hors UI (console / textarea
`Admin::UsersWithRolesController` qui sera conservé tant qu'on n'a pas de
flow dédié).

### 2. Étendre `User#manages_role?` pour les admins

Plutôt qu'introduire un `authority.can_manage?(role)` dans
`Instruction::MergeManagedRoles`, on enseigne à `User#manages_role?` à
retourner `true` pour un admin sur tout rôle non-`admin`. Conséquences :

- `MergeManagedRoles` reste agnostique (pas de changement de signature).
- `Instruction::UserRightsView#covered_rights` (qui utilise
  `manager.manages_role?(role_string)`) marche tel quel pour un admin.
- À surveiller : tout autre call site de `manages_role?` qui supposait
  implicitement le périmètre manager. Audit avant le merge.

### 3. Renommage `manager:` → `authority:`

Dans le form, le controller, l'interactor, la view, et les organizers :

- `Instruction::UserRightForm.new(authority:, user: nil, **attrs)`
- `Instruction::UserRightForm.for_edit(authority:, user:)`
- `Instruction::UserRightsView.new(authority:, user:)`
- `Instruction::MergeManagedRoles` → `context.authority` (au lieu de
  `context.manager`). `context.user.roles = preserved + incoming` reste,
  mais `manages_role?` est appelé sur `context.authority.user`.
- `Instruction::UpdateUserRights.call(authority:, user:, new_roles:)`.
  L'organizer met `context.admin = authority.user` pour le tracking
  `Admin::TrackEvent`.

`Instruction::ManagerScopeOptions` disparaît au profit de
`Rights::ManagerAuthority`.

### 4. Controllers — héritage léger via `render template:`

```ruby
class Admin::UserRightsController < AdminController
  before_action :build_authority

  def index
    @users = User.with_any_role_on(@authority.managed_definitions.ids)
                 .where.not(id: current_user.id)
                 .includes(:organizations)
                 .order(:email)
    render template: 'instruction/user_rights/index'
  end

  # new / create / edit / update / destroy / confirm_destroy
  # → mêmes corps que Instruction::UserRightsController, render template: explicite
  #   sur les vues sous app/views/instruction/user_rights/.

  private

  def build_authority
    @authority = Rights::AdminAuthority.new(current_user)
  end
end
```

Les vues restent sous `app/views/instruction/user_rights/` (pas de
déplacement). Les chemins (`instruction_user_rights_path` vs
`admin_user_rights_path`) sont résolus côté vue via un helper unique
(p.ex. `user_rights_index_path` qui regarde le namespace courant), à
décider en implémentant.

### 5. Policy admin

`Admin::UserRightPolicy < Instruction::UserRightPolicy` qui override
`enabled?` :

```ruby
class Admin::UserRightPolicy < Instruction::UserRightPolicy
  def enabled?
    user.admin?
  end

  def edit?
    enabled? && record != user  # admin gère tout, plus de can_manage_any_role?
  end
end
```

### 6. Routes

```ruby
namespace :admin do
  resources :user_rights, only: %i[index new create edit update destroy],
            path: 'gestion-des-droits' do
    member { get :confirm_destroy, path: 'confirmer-suppression' }
  end
end
```

### 7. Menu admin

Ajouter un lien « Gestion des droits » dans la navigation admin
(à co-localiser avec les liens vers `/admin/utilisateurs-avec-roles`,
`/admin/bans`, etc.).

### 8. Décommissionnement `Admin::UsersWithRolesController` — **pas dans cette PR**

Le textarea reste, parce qu'il sert à octroyer/révoquer le rôle `admin`
qui ne passe pas par la nouvelle UI. Décommissionnement à reconsidérer
quand un flow dédié pour le rôle admin existera (ou s'il est jugé
acceptable de continuer en console only).

---

## Livraison — une seule PR

`ManagerScopeOptions` existant rend le refactor petit. Une PR unique
contient :

1. Création de `Rights::Authority`, `Rights::ManagerAuthority`,
   `Rights::AdminAuthority` (+ specs).
2. Renommage `Instruction::ManagerScopeOptions` → `Rights::ManagerAuthority`
   (`git mv` + ajustement des call sites).
3. Renommage `manager:` → `authority:` dans
   `Instruction::UserRightForm`, `Instruction::UserRightsView`,
   `Instruction::MergeManagedRoles`,
   `Instruction::UpdateUserRights.call`,
   `Instruction::UserRightsController`.
4. Extension de `User#manages_role?` pour retourner `true` chez un admin
   (sauf rôle `admin` lui-même).
5. `Admin::UserRightsController` (+ `Admin::UserRightPolicy`) qui réutilise
   les vues `instruction/user_rights/*` via `render template:`.
6. Routes admin miroir.
7. Menu admin.
8. Features cucumber : dupliquer
   `features/instructeurs/gestion_des_droits/*` sous
   `features/admin/gestion_des_droits/` avec un contexte
   « Sachant que je suis un administrateur » + assertions admin
   (toutes définitions visibles, rôle developer sélectionnable, scope FD
   `<provider>:*` proposé partout).

Specs existants doivent rester verts moyennant `s/manager:/authority:/`
dans les setups. Les tests de `User#manages_role?` doivent gagner un cas
admin.

---

## Points encore à trancher en implémentant

- **Helper de path partagé** : `instruction_user_rights_path` vs
  `admin_user_rights_path` — méthode utilitaire unique côté vue, ou
  passer le path en variable depuis le controller. À voir au moment du
  diff.
- **Auto-notification admin** : `Admin::NotifyAdminsForRolesUpdate`
  envoie aux admins. Ne pas envoyer à l'admin qui effectue l'action
  lui-même. À vérifier dans le pipeline (`context.admin == recipient`).
- **Audit `User#manages_role?`** : lister tous les call sites avant
  de changer la sémantique. Aujourd'hui :
  `MergeManagedRoles`, `UserRightsView#covered_rights`, et potentiellement
  d'autres — à vérifier par grep.
- **Filtre par définition** côté admin (30+ définitions = liste longue) :
  la recherche par email a été ajoutée (commit `dbbb7342`), suffisante
  pour démarrer. Filtre par définition à reconsidérer si feedback admin.
