---
shaping: true
---

# Shaping — Interface de gestion des droits pour les managers FD (DP-1613)

---

## Contexte

La gestion des droits est aujourd'hui admin-only (`/admin/utilisateurs-avec-roles`). Un manager FD doit passer par l'équipe DataPass pour tout changement : nouvel instructeur, départ d'agent, changement de rôle.

Ce shaping définit une interface dans l'espace instructeur permettant à un manager FD de gérer les droits de son FD en autonomie. Elle s'appuie sur DP-1612 (droits FD-level, format `fd:{slug}:{role}` stocké dans `users.roles`).

---

## Requirements (R)

| ID | Requirement | Status |
|----|-------------|--------|
| R0 | Un manager FD voit tous les utilisateurs ayant des droits sur son FD, qu'ils soient en FD-level (`fd:{slug}:{role}`) ou en definition-level (`{definition_id}:{role}`), hors admins DataPass | Core goal |
| R1 | Un manager FD peut ajouter/modifier un droit en choisissant : email, portée (FD global = `fd:{slug}` ou une définition précise = `{definition_id}`), rôle (reporter/instructor/manager/developer) | Core goal |
| R2 | Un manager FD peut modifier le rôle d'un user existant | Must-have |
| R3 | Un manager FD peut retirer tous les droits d'un user sur son FD | Must-have |
| R4 | L'interface s'adapte à la portée du user : manager sur N FDs → voit ses N FDs ; admin → voit tous les FDs ; dans les deux cas il peut attribuer/modifier/retirer des droits (sauf le rôle admin) | Must-have |
| R5 | Accessible via onglet « Droits » dans la nav de l'espace instructeur, visible managers et admins uniquement | Must-have |
| R6 | Un manager ne peut pas attribuer des droits supérieurs aux siens | Must-have |
| R7 | Un manager peut gérer uniquement les droits des FDs sur lesquels il est lui-même manager | Must-have |
| R8 | Un manager ne peut pas se retirer ses propres droits de manager (auto-révocation bloquée) | Nice-to-have |
| R9 | Les modifications sont tracées (AdminEvent) et notifient les admins DataPass | Must-have |

---

## A: Interface de gestion des droits FD dans l'espace instructeur

| Part | Mécanisme |
|------|-----------|
| A1 | **Nav** : `InstructorMenuComponent` ajoute param `show_rights` → lien « Droits » conditionnel (manager? ou admin?) |
| A2 | **Liste** : `Instruction::UserRolesController#index` — liste les users avec droits sur tous les FDs accessibles au user courant (ses FDs de manager, ou tous les FDs si admin) via `User.with_rights_on_fd(data_providers)` ; admins DataPass exclus |
| A3 | **Ajout/Modif** : `#new` / `#create` / `#edit` / `#update` — formulaire 3 selectboxes : email (saisie, lookup user existant), portée (FD global = `fd:{slug}` ou définition précise), rôle (reporter/instructor/manager/developer) |
| A4 | **Suppression** : `#destroy` — retire les rôles FD-scoped d'un user (FD-level + definition-level du FD) |
| A5 | **Policy** : `Instruction::UserRolePolicy` — accès restreint aux managers de ce FD + admins ; vérifie non-élévation de privilège ; bloque auto-révocation |
| A6 | **Organizer** : `Instruction::UpdateUserFdRoles` — orchestre la modification atomique d'un rôle FD-scoped ; réutilise `Admin::TrackEvent` et `Admin::NotifyAdminsForRolesUpdate` pour R9 |
| A7 | **Scope User** : `User.with_rights_on_fd(data_providers)` — SQL sur `users.roles` pour `fd:{slug}:*` ou `{definition_id}:*` (toutes defs du FD) |

### Fit Check (R × A)

| Req | Requirement | Status | A |
|-----|-------------|--------|---|
| R0 | Manager voit tous les users avec droits FD-level et definition-level (hors admins) | Core goal | ✅ |
| R1 | Ajout/modif droit : portée FD-global ou définition précise + rôle | Core goal | ✅ |
| R2 | Modification rôle existant | Must-have | ✅ |
| R3 | Retrait droits user sur FD | Must-have | ✅ |
| R4 | Interface adaptée à la portée (N FDs pour manager multi-FD, tous FDs pour admin) | Must-have | ✅ |
| R5 | Onglet « Droits » dans nav instruction | Must-have | ✅ |
| R6 | Pas d'élévation de privilège | Must-have | ✅ |
| R7 | Manager limité à ses FDs de manager | Must-have | ✅ |
| R8 | Auto-révocation bloquée | Nice-to-have | ✅ |
| R9 | Traçage + notification admins | Must-have | ✅ |

---

## Décisions tranchées

- **Nommage de l'onglet** : « Droits »
- **Rôles gérables** : reporter, instructor, manager, developer (les 4 rôles)
- **Portée** : FD-global (`fd:{slug}:{role}`) et definition-level (`{definition_id}:{role}`) tous deux gérables
- **Admin / manager multi-FD** : vue unifiée sur tous les FDs accessibles
- **Admins DataPass** : non listés dans l'interface, gestion console uniquement
- **Formulaire** : selectboxes uniquement (pas de textarea)

---

## Points d'attention techniques

1. **`managed_authorization_definition_uids`** dans `Instruction::MessageTemplatesController` fait `role.split(':').first` sur `manager_roles`. Avec `fd:{slug}:manager`, ça retourne `fd` comme uid — à corriger dans DP-1612.
2. **User non trouvé** : si l'email saisi ne correspond à aucun user DataPass → erreur explicite, hors périmètre la création.

---

## Fichiers critiques

| Fichier | Action |
|---------|--------|
| `app/components/instructor_menu_component.rb` | Ajouter param `show_rights` |
| `app/components/instructor_menu_component.html.erb` | Ajouter lien conditionnel « Droits » |
| `app/controllers/instruction/user_roles_controller.rb` | Nouveau contrôleur |
| `app/policies/instruction/user_role_policy.rb` | Nouveau Pundit policy |
| `app/organizers/instruction/update_user_fd_roles.rb` | Nouvel organizer |
| `app/models/user.rb` | Ajouter `with_rights_on_fd` scope |
| `app/views/instruction/user_roles/` | Vues index, new, edit |
| `config/routes.rb` | Ajouter resource dans namespace instruction |
| `spec/components/previews/instructor_menu_component_preview.rb` | Mettre à jour preview |
