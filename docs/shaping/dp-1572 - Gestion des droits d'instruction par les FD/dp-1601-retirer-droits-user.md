---
shaping: true
---

# DP-1601 — Retirer entièrement les droits d'un utilisateur

## Context

Dans l'interface admin `/admin/utilisateurs-avec-roles`, le champ « Rôles » est marqué `required: true` dans la vue. Cela empêche de sauvegarder un formulaire avec un champ vide, rendant impossible de retirer tous les droits d'un utilisateur. C'est bloquant pour maintenir une base d'utilisateurs propre (départ d'orga, compte compromis, etc.).

---

## Requirements (R)

| ID | Requirement | Status |
|----|-------------|--------|
| R0 | Un admin DataPass peut retirer la totalité des droits d'un utilisateur via l'interface | Core goal |
| R1 | L'utilisateur sans droits n'apparaît plus dans la liste `/admin/utilisateurs-avec-roles` | Must-have |
| R2 | Le changement est tracé (AdminEvent) et notifié par email aux admins | Must-have |

---

## A: Permettre la sauvegarde avec le champ Rôles vide

Supprimer `required: true` du champ textarea.

| Part | Mechanism |
|------|-----------|
| A1 | Vue `new.html.erb` : retirer `required: true` du `dsfr_text_area :roles` |

---

## Fit Check

| Req | Requirement | Status | A |
|-----|-------------|--------|---|
| R0 | Admin peut retirer tous les droits via l'interface | Core goal | ✅ |
| R1 | L'utilisateur sans droits disparaît de la liste | Must-have | ✅ |
| R2 | Tracé + notifié | Must-have | ✅ |

**Notes :**
- R1 : la scope `with_roles` filtre déjà les users avec `roles != '{}'` — aucun changement nécessaire.
- R2 : l'organizer `Admin::UpdateUserRoles` appelle déjà `Admin::TrackEvent` et `Admin::NotifyAdminsForRolesUpdate` — aucun changement nécessaire.

---

## Shape sélectionnée : A

### Analyse technique

Le contrôleur (`Admin::UsersWithRolesController#user_roles_param`) gère déjà les rôles vides :
```ruby
roles = user_params[:roles] || ''
roles.split("\n").map(&:strip)  # '' → []
```
L'interacteur (`Admin::UpdateUserRolesAttribute`) filtre `[]` → `[]` et sauvegarde `user.roles = []`. Tout le pipeline aval (tracking, notification) fonctionne déjà.

### Fichiers à modifier

1. **Vue** : `app/views/admin/users_with_roles/new.html.erb` ligne 6
   - Retirer `required: true` du `dsfr_text_area :roles`

### Tests à ajouter

2. **Cucumber** : `features/admin/utilisateurs_avec_roles.feature`
   - Scénario : un admin retire tous les droits d'un utilisateur existant → l'utilisateur disparaît de la liste

### Vérification

1. `make e2e features/admin/utilisateurs_avec_roles.feature`
2. Manuellement : éditer un utilisateur avec droits, vider le champ Rôles, sauvegarder → vérifier qu'il disparaît de la liste
