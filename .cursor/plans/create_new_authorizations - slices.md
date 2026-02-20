---
shaping: true
---

# Création de types d'habilitation dans l'UI — Slices

Reference: [Shaping doc](./create_new_authorizations%20-%20shaping.md)

---

## Slice overview

| Slice | What it delivers | Key parts |
|-------|-----------------|-----------|
| **V1** | End-to-end proof: admin creates a minimal type, edits/deletes it, applicant fills it, instructor reviews | A1, A2, A3, A5 (minimal), A7 (no requests) |
| **V2** | Block selection + scopes + contacts + destructive edit/delete with confirmation | A3 (extended), A5 (extended), A7 (with requests) |
| **V3** | Full configuration: links, labels, provider creation, introduction | A4, A5 (complete), A6 |

Each slice is demo-able: the admin can show something working at the end of each.

---

## V1: End-to-end proof

**Goal:** Prove the entire architecture works. Admin creates the simplest
possible type, and it works end-to-end through the full lifecycle.

### What's in V1

| Layer | What |
|-------|------|
| **Migration** | `authorization_definition_records` table (all columns — build the full schema now, even if UI doesn't expose everything yet). `authorization_request_form_records` table. |
| **Models** | `AuthorizationDefinitionRecord` + `AuthorizationRequestFormRecord` ActiveRecord models with validations. |
| **Hybrid backend** | Override `backend` in `AuthorizationDefinition` and `AuthorizationRequestForm` to merge YAML + DB. Add `build_from_record`. Add `reset!` to `StaticApplicationRecord`. |
| **Dynamic classes** | `DynamicAuthorizationTypeRegistrar` service. `to_prepare` initializer. Only includes `BasicInfos` concern (hardcoded — all V1 types get basic_infos). |
| **Admin UI** | New page in admin panel: form with name, description, provider (select existing), kind (api/service). No block selection yet — basic_infos is always included. List page shows edit/delete buttons per type. |
| **Edit** | Same form pre-filled with existing values. Updates DB record + re-registers dynamic class + resets caches. Only available when no requests exist. |
| **Delete (no requests)** | Destroy DB record + unregister dynamic class (`remove_const`) + reset caches. Simple confirmation (standard browser confirm). |
| **Auto-generate form** | On creation, automatically create the associated `AuthorizationRequestFormRecord` with steps derived from blocks. |
| **UID validation** | Uniqueness across YAML + DB sources. |

### What's NOT in V1

- No block selection (all V1 types get basic_infos only)
- No scopes, contacts, legal, personal_data blocks
- No link/cgu_link/access_link/support_email fields
- No custom labels
- No provider creation
- No form introduction
- No cascade deletion (types with existing requests cannot be deleted yet)

### Demo

1. Admin goes to admin panel → "Nouveau type d'habilitation"
2. Fills: name="Test API", description="Une API de test", provider=DINUM, kind=api
3. Clicks create
4. Type appears in the public index alongside the 55+ YAML-based types
5. Admin clicks edit → changes description → saves → updated in index
6. Applicant starts a request for "Test API"
7. Fills basic_infos step (intitule + description)
8. Submits
9. Instructor can review the request
10. Admin creates another type "Test API 2" (no requests yet) → deletes it → gone

**What this proves:**
- Hybrid backend works (YAML + DB types in the same list)
- Dynamic class generation works (STI resolves correctly)
- Default block partials render for DB-based types
- Full request lifecycle works (draft → submit → review)
- Edit updates the type in place and re-registers the dynamic class
- Delete cleanly removes types with no requests

---

## V2: Block selection + scopes + contacts

**Goal:** The bizdev can pick which blocks a type includes, configure scopes,
and choose contact types.

### What's in V2

| Layer | What |
|-------|------|
| **Admin UI** | Block checkboxes (basic_infos, legal, personal_data, contacts, scopes) — all checked by default. When contacts is checked, show contact type checkboxes (contact_technique, contact_metier, responsable_traitement, delegue_protection_donnees). Scopes builder: add/remove rows with name, value, group. |
| **Dynamic classes** | `DynamicAuthorizationTypeRegistrar` now reads block config and conditionally includes: `BasicInfos`, `CadreJuridique`, `PersonalData`, `GDPRContacts` (if selected), specific contacts, `add_scopes`. |
| **Form generation** | Steps auto-derived from selected blocks in fixed order: basic_infos → legal → scopes → personal_data → contacts. Only selected blocks become steps. |
| **Destructive confirmation** | Edit and delete now work even when requests exist. Both trigger the same confirmation page showing: request count, sample organization names (up to 3 + « etc... »). Message: « Cette action va SUPPRIMER N DEMANDES. Ces demandes proviennent (entre autres) de ORG1, ORG2, ORG3, etc... Êtes vous sûrs, super sûrs de vouloir faire ça ? ». Confirm button disabled for 5 seconds (countdown). On confirm: cascade-destroy all requests + authorizations, then apply edit or delete. |

### Demo

1. Admin creates a type with only basic_infos + scopes (unchecks legal, personal_data, contacts)
2. Adds 3 scopes: "Nom" (family_name, Identité), "Prénom" (given_name, Identité), "Email" (email, Contact)
3. Applicant starts a request → sees a 2-step form (basic_infos, scopes)
4. Selects scopes, submits
5. Instructor reviews — only basic_infos and scopes blocks in summary
6. Admin tries to delete the type → sees confirmation: « Cette action va SUPPRIMER 1 DEMANDE. Ces demandes proviennent (entre autres) de COMMUNE DE TEST, etc... Êtes vous sûrs, super sûrs de vouloir faire ça ? » → waits 5 seconds → confirms → type and request are gone
7. Admin creates another type with requests → edits it (changes scopes) → same confirmation appears → waits 5 seconds → confirms → requests destroyed, edit applied

**What this proves:**
- Dynamic concern inclusion works per-type
- Scopes defined in DB work correctly in the form and summary
- Contact configuration works
- Block selection drives form steps
- Destructive confirmation works for both edit and delete, with 5-second safety delay

---

## V3: Full configuration

**Goal:** All remaining configuration options. The admin can create a
fully-featured type indistinguishable from a YAML-based one.

### What's in V3

| Layer | What |
|-------|------|
| **Admin UI** | Remaining fields: link, cgu_link, access_link (with explanation), support_email. Legal label customization (nature label, nature hint, justificatif title — pre-filled with defaults). Form introduction text field. DataProvider inline creation (select existing or create new). |
| **I18n from DB** | `custom_label_for` in `AuthorizationRequestFormBuilder.wording_for`. `custom_labels` exposed on `AuthorizationDefinition`. |
| **DataProvider creation** | "Créer un nouveau fournisseur" option in provider dropdown → inline form or modal. |

### Demo

1. Admin creates a type:
   - Provider: "Nouveau fournisseur" → creates "Mon Fournisseur" inline
   - All blocks selected
   - Custom legal labels: "Précisez votre base réglementaire" (instead of default)
   - Scopes configured
   - Introduction text: "Bienvenue sur le formulaire de Mon Fournisseur..."
   - CGU link, access link, support email filled
2. Applicant starts a request → sees introduction text → fills all steps → legal block shows custom labels
3. After approval, applicant sees access link
4. Full feature parity with YAML-based types

**What this proves:**
- Custom labels work through the existing I18n cascade
- DataProvider inline creation works
- The type is indistinguishable from a YAML-based type for the end user

---

## Slice → Shape parts mapping

| Part | V1 | V2 | V3 |
|------|:--:|:--:|:--:|
| A1 — Hybrid backend | ✅ | | |
| A2 — DB tables | ✅ | | |
| A3 — Dynamic classes | ✅ (basic_infos only) | ✅ (all blocks) | |
| A4 — I18n from DB | | | ✅ |
| A5 — Admin UI | ✅ (minimal) | ✅ (blocks + scopes + contacts) | ✅ (complete) |
| A6 — DataProvider creation | | | ✅ |
| A7 — Type lifecycle | ✅ (edit + delete, no requests) | ✅ (destructive edit/delete with confirmation + 5s delay) | |
