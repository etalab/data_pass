# Context

Read this PR : https://github.com/etalab/data_pass/pull/1595/ 
This was a prototype of rough display of the formulaires (definitions) and cas d'usages (forms).

Then read this PR : https://github.com/etalab/data_pass/pull/1607.
This was built over the previous PR, and is a prototype of pretty display of the formulaires and cas d'usages.

Now my plan is to start over from develop to make these features, and I'll use the inspiration of this design : /home/caillou/Downloads/DataPass%20-%20Fiche%20&%20cas%20d'usage%20(standalone).html

But first, we are going to explore the code of the prototypes.

# Explore the prototypes

Explore the 2 PRs and tell me what should be reconsidered in the controllers and models to make it clean and respect the datapass' guidelines.

> Response was a very detailed review, but actually I first need a summary of what was done to the models

## Actually

Actually, I first need a summary of the PR's changes to the models

## Summary of the model changes

> Claude's answer

All model changes are in PR 1595 only — PR 1607 touched no models. Here's the summary:

---

### New model: `FormTemplate`

A new ActiveRecord model backed by the `form_templates` table. It sits between `HabilitationType` (DB) and `AuthorizationRequestForm` (façade).

**Schema:** `slug`, `name`, `description`, `introduction`, `use_case`, `default`, `public`, `startable_by_applicant`, `single_page_view`, `service_provider_id` (string, FK to YAML-backed `ServiceProvider`), plus jsonb columns `steps`, `static_blocks`, `scopes_config`, `initialize_with`.

**Key behaviors:**
- `friendly_id` on `name`, `paper_trail` versioning
- `belongs_to :habilitation_type`
- Validates that the slug doesn't collide with any YAML-defined form uid (`slug_not_taken_by_yaml`)
- Enforces exactly one `default: true` per `HabilitationType` (via `only_one_default_per_habilitation_type`, `ht_keeps_at_least_one_default`, and `ensure_not_last_default` on `before_destroy`)
- `after_commit :reset_arf_cache` — invalidates the `AuthorizationRequestForm` in-memory cache (via Redis) whenever a template is created, updated, or destroyed
- `service_provider` is resolved at read time via `ServiceProvider.find(service_provider_id)`, returning `nil` gracefully if not found

---

### Modified: `HabilitationType`

- Added `has_many :form_templates, dependent: :destroy`
- Added `after_create :ensure_default_form_template!` — when a new `HabilitationType` is created, it immediately creates one default `FormTemplate` with slug `"#{slug}-default"`, seeding it with empty jsonb columns (steps/scopes cascade from the HT at render time)
- `after_save :reset_static_caches` and `after_destroy :reset_static_caches` replaced by a single `after_commit :reset_static_caches, on: %i[create update destroy]` — avoids firing before the transaction is committed

---

### Modified: `AuthorizationRequestForm` (the YAML/DB façade)

The façade previously iterated `HabilitationType` directly; it now iterates `FormTemplate`.

- `db_records` now does `FormTemplate.includes(:habilitation_type).filter_map { build_form_from_template(template) }` instead of building one form per `HabilitationType`. This means one `HabilitationType` can now produce **N forms** (one per `FormTemplate`) rather than always exactly one.
- `build_form_from_template` maps all `FormTemplate` columns to form attributes, with cascading fallback to `HabilitationType` for `name`, `description`, `introduction`, and `steps` when the template columns are blank.
- New attribute `form_template` exposed on the façade to carry the originating `FormTemplate` record.
- `inherited?(field)` — returns `true` if the given field (`name`, `description`, `introduction`, `steps`) is blank on the underlying `FormTemplate` (i.e. it fell back to the `HabilitationType` value).
- `from_database?` — returns `true` if the form came from a `FormTemplate` (vs a YAML record).


---

## We dont' want the in-db cas d'usages (form_templates) yet.

Ok, so I understand the PR 1595 introduces a in-db model for the cas d'usages (form_templates), but I don't want to do that yet. The work I want to do is to  _only_ display formulaires (definitions) and cas d'usages (forms) for the instructors and managers.

Can you summarize the model changes left if we ignore this ? (I think there should be none). Then summarize the controllers changes if we ignore this.

## Model changes without `FormTemplate`

> Claude's answer

None. Every model change in PR 1595 exists purely to introduce and support `FormTemplate`:
- `HabilitationType` changes (`has_many :form_templates`, `after_create :ensure_default_form_template!`, callback timing fix) are all in service of `FormTemplate`
- `AuthorizationRequestForm` changes (`build_form_from_template`, `inherited?`, `from_database?`, `form_template` attribute) are all wiring `FormTemplate` into the façade

The existing `AuthorizationDefinition` + `AuthorizationRequestForm` (YAML-backed) are already sufficient to display formulaires and cas d'usages. Zero model changes needed.

---

## Controller changes, ignoring `FormTemplate`

> Claude's answer

Everything still applies — the controllers only read `AuthorizationDefinition` and `AuthorizationRequestForm`, neither of which requires `FormTemplate`.

**From PR 1595 (new infrastructure):**
- `Instruction::DataProvidersController` — `index` listing providers the current user has reporter access to
- `Instruction::AbstractCatalogueController` — `before_action :set_data_provider` (find by slug + authorize), shared parent for the two below
- `Instruction::FormulairesController` — `index` filtering `authorization_definitions` by policy, `show` loading `available_forms` and counts
- `Instruction::CasUsagesController` — `show` finding a specific form by uid within a formulaire
- 3 Pundit policies (`DataProviderPolicy`, `AuthorizationDefinitionPolicy`, `AuthorizationRequestFormPolicy`)
- Routes: `/instruction/fournisseurs-donnees` + nested formulaires + cas-usage

**From PR 1607 (visual prototype built on top):**
- `FormulairesController#show` extended with: `@authorization_request` stub (for WYSIWYG preview), stats counts, email count
- `CasUsagesController#index` added, `show` extended with stats counts
- `Instruction::EmailsAutomatiquesController` + `AutomaticEmailsCatalog` service — entirely independent of `FormTemplate`
- `DashboardController` — navigation shortcut to the provider/formulaire list
- Various views, partials, CSS, locales





