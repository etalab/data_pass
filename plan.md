# Plan : DP-1601 - Pouvoir retirer entièrement des droits à un user avec droits

## Contexte

**Ticket** : [DP-1601](https://linear.app/pole-api/issue/DP-1601/pouvoir-retirer-entierement-des-droits-a-un-user-avec-droits)
**Branche** : `feature/dp-1601-pouvoir-retirer-entierement-des-droits-a-un-user-avec-droits`
**Statut** : In Review (assigné à valentin.shamsnejad@beta.gouv.fr)

**Besoin** : ETQ admin DataPass, je peux retirer la totalité des droits d'un utilisateur via l'interface admin (`/admin/utilisateurs-avec-roles`), pour maintenir une base d'utilisateurs propre (départ d'une orga, compromission de compte, etc.).

## Analyse de l'existant

### Cause du problème

Dans la vue `app/views/admin/users_with_roles/new.html.erb` (ligne 6), le champ `Roles` est défini avec `required: true` :

```erb
<%= f.dsfr_text_area :roles, value: @user.roles.split(',').join("\n"), required: true, ... %>
```

Cela génère un attribut HTML `required` qui empêche le navigateur de soumettre le formulaire si le champ est vide. C'est la **seule** contrainte qui bloque : il n'y a **aucune** validation côté modèle (`User`) ni côté interactor sur la présence de rôles.

### Ce qui fonctionne déjà côté backend

Le backend gère correctement le cas d'un tableau de rôles vide :
- **Controller** (`user_roles_param`) : `''.split("\n")` → `[]`
- **Interactor** (`UpdateUserRolesAttribute`) : `valid_roles` filtre les rôles invalides, un tableau vide reste `[]`
- **Model** (`User`) : pas de validation `presence` sur `roles`, `user.save` réussit avec `roles = []`
- **Scope** (`User.with_roles`) : filtre `where("roles <> '{}'")`, donc un utilisateur sans rôles disparaît de la liste des utilisateurs avec rôles

## Fichiers à modifier

| Fichier | Modification |
|---------|-------------|
| `app/views/admin/users_with_roles/new.html.erb` | Retirer `required: true` sur le champ Roles |
| `spec/organizers/admin/update_user_roles_spec.rb` | Ajouter test pour rôles vides |
| `features/admin/utilisateurs_avec_roles.feature` | Ajouter scénario de retrait de tous les rôles |
| `features/step_definitions/` | Step definition pour vider un champ si nécessaire |

## Étapes d'implémentation

### Étape 1 : Modifier la vue — retirer `required: true` sur le champ Roles

**Fichier** : `app/views/admin/users_with_roles/new.html.erb` (ligne 6)

**Changement** : Remplacer `required: true` par `required: false` sur le `dsfr_text_area :roles`.

```diff
- <%= f.dsfr_text_area :roles, value: @user.roles.split(',').join("\n"), required: true, placeholder: t('.form.roles.placeholder'), rows: 20 %>
+ <%= f.dsfr_text_area :roles, value: @user.roles.split(',').join("\n"), required: false, placeholder: t('.form.roles.placeholder'), rows: 20 %>
```

C'est le seul changement de code fonctionnel nécessaire. Le backend gère déjà correctement les rôles vides.

### Étape 2 : Ajouter un test RSpec pour le cas des rôles vides

**Fichier** : `spec/organizers/admin/update_user_roles_spec.rb`

**Changement** : Ajouter un contexte qui teste le cas `roles: []` :
- Vérifier que l'organizer réussit (`is_expected.to be_success`)
- Vérifier que les rôles de l'utilisateur deviennent `[]`
- Vérifier qu'un `AdminEvent` est bien créé (traçabilité du retrait de droits)
- Vérifier qu'un email de notification est envoyé aux admins

### Étape 3 : Ajouter un scénario Cucumber

**Fichier** : `features/admin/utilisateurs_avec_roles.feature`

**Changement** : Ajouter un scénario :

```gherkin
Scénario: Je peux retirer tous les rôles d'un utilisateur
  Quand il y a l'utilisateur "api-entreprise@gouv.fr" avec le rôle "Instructeur" pour "API Entreprise"
  Et que je me rends sur le module "Utilisateurs avec rôles" de l'espace administrateur
  Et que je clique sur "Éditer" pour l'utilisateur "api-entreprise@gouv.fr"
  Et que je vide le champ "Role"
  Et que je clique sur "Mettre à jour"
  Alors il y a un message de succès contenant "mis à jour"
  Et la page ne contient pas "api-entreprise@gouv.fr"
```

Il faudra peut-être ajouter un step definition pour « je vide le champ "Role" » (remplir avec une chaîne vide via `fill_in`).

### Étape 4 : Vérifier que les tests passent

- `bundle exec rspec spec/organizers/admin/update_user_roles_spec.rb`
- `bundle exec cucumber features/admin/utilisateurs_avec_roles.feature`
- `bundle exec rubocop`

## Décisions prises

- **Branche** : on travaille sur la branche courante (`feature/dp-1601-pouvoir-retirer-entierement-des-droits-a-un-user-avec-droits`), pas de changement nécessaire.
- **Pas de confirmation** : le champ vide + bouton « Mettre à jour » est suffisant comme point de friction.
- **Disparition de la liste** : comportement attendu. Un utilisateur sans rôles ne doit plus apparaître dans `/admin/utilisateurs-avec-roles`.
