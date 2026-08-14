# Implement log — DP-1734

Plan : `.notes/plan.md` (READY, 5 décisions tranchées).
Mode : option (b) — étape par étape, pause validation JB après chaque étape.

- [x] Étape 1 — Modèle : projections + scopes de filtrage — done 2026-08-13 (commit `a602c4e0`, amendé)
  - `User#distinct_role_types`, `User#specific_authorization_definitions` (concern `UserRoles`)
  - scopes `with_role_type`, `with_specific_definition`,
    `with/without_specific_definition_rights` (`user.rb`)
  - `without_roles` retiré (parking « sans rôle » → pas de code mort — décision JB 2026-08-13)
  - specs : `spec/models/concerns/user_roles_spec.rb` + `spec/models/user_spec.rb`
  - **90 exemples verts, rubocop clean**
  - ⏸️ **PAUSE validation JB avant Étape 2**

- [x] Étape 2 — Service/Query : recherche multi-filtres cumulables — done 2026-08-13 (commit `790c699c`)
  - `Instruction::UserRightsSearch` étendu : `role_type` + `droit` (with/without/`<definition_id>`)
    composés en intersection par-dessus la recherche texte, base = scope autorité
  - readers `role_type` / `droit` exposés (état sélectionné pour la vue Étape 3)
  - tête « avec/sans rôle » (RG7) parquée, non exposée
  - specs : `spec/models/instruction/user_rights_search_spec.rb` — **19 exemples verts, rubocop clean**
  - ⏸️ **PAUSE validation JB avant Étape 3**
- [x] Étape 3 — Contrôleur + vues : index fusionné — done 2026-08-13 (commit `7db0cb29`)
  - `.per(10)` (RG5) + `@role_filter`/`@droit_filter` exposés (admin + instruction)
  - barre de filtres (selects Droits/Rôles + Réinitialiser) dans le form GET auto-submit
  - `UserRightsHelper` : options role_types + définitions (tri nil-safe) ; status message
    étendu aux filtres actifs ; i18n `…index.filters.*`
  - request specs instruction + admin (`spec/requests/.../user_rights_spec.rb`) — **7 verts, rubocop clean**
  - Nav + renommage titre volontairement REPOUSSÉS en Étape 7 (couplés au retrait users_with_roles)
  - ⏸️ **PAUSE validation JB avant Étape 4**
- [ ] Étape 4 — Composants : ligne enrichie + cellule Droits + badges vides
- [ ] Étape 5 — Cucumber : CA-1 → CA-7
- [ ] Étape 6 — Fix Valentin (admin ⇒ *:*:*, dérivé de admin?)
- [ ] Étape 7 — Nettoyage + qualité
