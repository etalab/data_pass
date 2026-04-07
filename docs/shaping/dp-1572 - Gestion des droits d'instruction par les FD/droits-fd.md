---
shaping: true
---

# Shaping — Droits de niveau FD (DP-1612)

---

## Contexte

Gérer les rôles par définition est fastidieux quand un FD (Fournisseur de Données) a beaucoup de définitions :
- Nouvelle définition → ajouter manuellement les rôles à tous les users existants du FD
- Nouvel instructeur → lui donner son rôle sur chaque définition du FD

**Pitch** : un droit donné au niveau d'un FD s'applique automatiquement à toutes ses définitions, actuelles et futures.

---

## Requirements (R)

| ID | Requirement | Status |
|----|-------------|--------|
| R0 | Un droit FD-level s'applique à toutes les définitions actuelles et futures du FD | Core goal |
| R1 | S'applique aux 4 rôles : reporter, instructor, manager, developer | Must-have |
| R2 | Droits FD-level et definition-level coexistent pour un même user | Must-have |
| R3 | L'admin attribue des droits FD-level via l'UI textarea existante | Must-have |
| R4 | Aucune action manuelle nécessaire à l'ajout d'une définition au FD | Core goal |

---

## Shape A : `fd:{slug}:{role}` dans l'array existant (sélectionné)

### Mécanisme

Nouveau format de rôle stocké dans le tableau `users.roles` : `fd:{data_provider_slug}:{role}`
Exemple : `fd:dgfip:instructor`, `fd:api_entreprise:developer`

Les méthodes de rôle expandent dynamiquement les rôles FD-level en rôles definition-level.

| Part | Mécanisme |
|------|-----------|
| A1 | Nouveau format `fd:{data_provider_slug}:{role}` dans `users.roles` |
| A2 | `User#reporter_roles`, `instructor_roles`, `manager_roles`, `developer_roles` : expandent les rôles `fd:*:*` en `{definition_id}:{role}` via `DataProvider#authorization_definitions` |
| A3 | `User#instructor?(type)`, `manager?(type)`, `reporter?(type)` : bénéficient du changement en cascade via les `*_roles` |
| A4 | Scopes DB `User.instructor_for(type)` etc. : incluent aussi `fd:{provider_slug}:{role}` dans la condition SQL |
| A5 | `Admin::UpdateUserRolesAttribute` : validation étendue pour accepter `fd:{valid_slug}:{role}` |
| A6 | `admin/users_with_roles/new.html.erb` : instructions enrichies (format FD + liste des codes FD) |
| A7 | `DataProvider#reporters` / `DataProvider#instructors` : incluent les users avec rôles FD-level |

### Fit Check (R × A)

| Req | Requirement | Status | A |
|-----|-------------|--------|---|
| R0 | Droit FD-level sur toutes les définitions actuelles et futures | Core goal | ✅ |
| R1 | 4 rôles supportés | Must-have | ✅ |
| R2 | Coexistence FD-level et definition-level | Must-have | ✅ |
| R3 | Attribution via UI textarea existante | Must-have | ✅ |
| R4 | Pas d'action manuelle à l'ajout d'une définition | Core goal | ✅ |

---

## Fichiers critiques à modifier

- `app/models/user.rb` — expansion FD-level dans `*_roles` + méthodes `instructor?` etc.
- `app/models/data_provider.rb` — `reporters` / `instructors` incluent FD-level
- `app/interactors/admin/update_user_roles_attribute.rb` — validation du format `fd:*:*`
- `app/views/admin/users_with_roles/new.html.erb` — instructions + liste FD codes
- Specs associées

## Vérification

1. Créer un user avec rôle `fd:dgfip:instructor`
2. Vérifier qu'il peut instruire toutes les définitions DGFIP
3. Ajouter une nouvelle définition DGFIP → vérifier l'accès automatique
4. Vérifier que les scopes DB (`User.instructor_for`) remontent bien ce user
5. Vérifier que la validation rejette `fd:inconnu:instructor` (slug inexistant)
6. Vérifier que definition-level et FD-level coexistent pour un même user
