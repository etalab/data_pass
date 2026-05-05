# Plan de review — PR #1493

Reviewer : **Isalafont** (humain) + **Copilot** (bot)
Dernier review : 2026-04-13

---

## Commentaires Copilot (bot) — déjà traités ✅

1. **`deep_dup` au lieu de `dup`** — ✅
2. **`blank?` vs `nil` pour les booléens** — ✅
3. **Doc `private_reason`** — ✅

---

## Issue 1 : Passer `show_private_reason:` au composant ✅

**Décision** : YES — extraire `current_user` du composant

**Changements effectués** :
- `app/components/historical_authorization_request_event_component.rb` : ajout paramètre `show_private_reason: false` à `initialize`, `show_private_reason?` utilise `@show_private_reason` au lieu de `helpers.try(:current_user)&.admin?`
- `app/views/instruction/authorization_request_events/index.html.erb` : passe `show_private_reason: current_user&.admin?`
- `spec/components/historical_authorization_request_event_component_spec.rb` : specs mises à jour sans mock de `current_user`

**Tests** : 26 specs OK, 3 scénarios cucumber OK

---

## Issue 2 : Expliquer pourquoi `admin_change` utilise `:details` et non `:changelog` ✅

**Décision** : YES — explication postée en réponse au commentaire d'Isalafont sur la PR

---

## Issue 3 : Ajouter un guard `raise` si `changed?` avant `reload` ✅

**Décision** : YES

**Changements effectués** :
- `app/interactors/admin/build_admin_change_diff.rb` : extraction de `execute_block` avec `raise` si `changed?`, message dans les locales
- `config/locales/admin.fr.yml` : ajout clé `admin.build_admin_change_diff.unsaved_changes`
- `spec/interactors/admin/build_admin_change_diff_spec.rb` : test du raise ajouté

**Tests** : 4 specs OK

---

## Résultat final

Tous les tests passent (30 specs + 3 scénarios cucumber). Rubocop OK. Aucun test en échec.
