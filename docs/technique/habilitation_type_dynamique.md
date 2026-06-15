# Système `HabilitationType` dynamique

Ce document décrit l'architecture du système d'habilitations gérées en base
de données (`HabilitationType`, slug suffixé `-dyn`). Pour ajouter un block
à une habilitation dynamique, voir [ajout_block_dynamique.md](./ajout_block_dynamique.md).
Pour les types YAML legacy, voir [ajout_nouveau_bloc_de_formulaire.md](./ajout_nouveau_bloc_de_formulaire.md).

## Vue d'ensemble

Flux nominal d'un save :

```
HabilitationType.save!
   │
   ├── after_save :register_dynamic_class
   │     └── DynamicAuthorizationRequestRegistrar.call(self)
   │           ├── Class.new(AuthorizationRequest)
   │           ├── apply_block(klass, block) ×N    (BLOCK_MODULES + BLOCK_PROCS)
   │           └── const_set("AuthorizationRequest::<Uid>Dyn", klass)
   │
   └── after_save :reset_static_caches
         ├── AuthorizationDefinition.reset!     (flush + bump Redis)
         ├── AuthorizationRequestForm.reset!    (flush + bump Redis)
         └── User.add_instruction_boolean_settings(...)
```

`AuthorizationDefinition` et `AuthorizationRequestForm` exposent un backend
mixte `yaml_records + db_records` : tout consommateur (`find`, `all`)
fonctionne indistinctement sur YAML et DB.

## Modèle DB

Fichier : [`app/models/habilitation_type.rb`](.../../app/models/habilitation_type.rb).
Migration : [`db/migrate/20260225111739_create_habilitation_types.rb`](../db/migrate/20260225111739_create_habilitation_types.rb).

Constantes structurantes :

```ruby
BLOCK_ORDER = %w[basic_infos legal personal_data scopes contacts].freeze
DEFAULT_BLOCKS = %w[basic_infos legal personal_data].freeze
VALID_RUBY_CLASSNAME = /\A[A-Z][a-zA-Z0-9]*\z/
EDITORIAL_PARAMS = %i[name description form_introduction link cgu_link access_link support_email].freeze
```

- `BLOCK_ORDER` dicte l'ordre du wizard. Un block enregistré au registrar mais
  absent de cette liste est inactif côté UI (gating volontaire — cf. pattern
  `cnous_data_extraction_criteria`).
- `EDITORIAL_PARAMS` et `EDITORIAL_SCOPE_PARAMS` figent les champs qu'un PO
  peut éditer après création — protège la stabilité d'API (uid, value des
  scopes).

Slug `friendly_id` suffixé `-dyn` :

```ruby
def normalize_friendly_id(input)
  "#{input.to_s.parameterize}-dyn"
end

def should_generate_new_friendly_id?
  slug.blank?  # ne regénère jamais le slug après création
end
```

Le suffixe garantit l'absence de collision avec un uid YAML legacy
(défense en profondeur via la validation `slug_not_taken_by_yaml`).

Lifecycle :

```ruby
before_destroy :ensure_no_authorization_requests   # throw :abort si demandes existantes
after_destroy  :unregister_dynamic_class
after_destroy  :reset_static_caches
after_save     :register_dynamic_class
after_save     :reset_static_caches
```

Versioning via `paper_trail` (versioning des **types** ; à distinguer du
`AuthorizationRequestChangelog` qui versionne les **demandes**).

## Registrar dynamique

Fichier : [`app/services/dynamic_authorization_request_registrar.rb`](.../../app/services/dynamic_authorization_request_registrar.rb).

Deux familles de blocks :

```ruby
BLOCK_MODULES = {
  'basic_infos'   => AuthorizationExtensions::BasicInfos,
  'legal'         => AuthorizationExtensions::CadreJuridique,
  'personal_data' => AuthorizationExtensions::PersonalData,
  'cnous_data_extraction_criteria' => AuthorizationExtensions::CnousDataExtractionCriteria,
}.freeze

BLOCK_PROCS = {
  'scopes'   => lambda { |klass, _record| klass.add_scopes(...) },
  'contacts' => lambda { |klass, record|  record.contact_types.each { ... } },
}.freeze
```

| Famille | Quand l'utiliser |
| --- | --- |
| `BLOCK_MODULES` | Le block est entièrement défini par un module. Aucun attribut du record n'est lu pour générer la DSL. |
| `BLOCK_PROCS` | Le block lit des attributs du record (`scopes`, `contact_types`) pour générer la DSL au cas par cas. |

Création de la classe STI :

```ruby
def call
  return Rails.logger.error(...) unless valid_class_name?

  klass = Class.new(AuthorizationRequest)
  @record.blocks.each { |block| apply_block(klass, block) }
  AuthorizationRequest.send(:remove_const, class_name) if AuthorizationRequest.const_defined?(class_name, false)
  AuthorizationRequest.const_set(class_name, klass)   # idempotent : remove avant set
end
```

Block inconnu → `Sentry.capture_message(level: :warning)`, pas de crash.

Initializer Rails — [`config/initializers/dynamic_authorization_types.rb`](../../config/initializers/dynamic_authorization_types.rb) :

```ruby
Rails.application.config.to_prepare do
  next unless defined?(HabilitationType) &&
              HabilitationType.table_exists? &&
              HabilitationType.any?

  HabilitationType.find_each { |record| DynamicAuthorizationRequestRegistrar.call(record) }
rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
  nil
end
```

`config.to_prepare` rejoue le registrar à chaque reload (Spring, eager_load,
worker boot). Le rescue couvre `db:create` / `db:drop` / première migration.

## Concerns blocks

Fichiers : [`app/models/concerns/authorization_extensions/*.rb`](.../../app/models/concerns/authorization_extensions/).
DSL réutilisable : [`app/models/concerns/authorization_core/`](.../../app/models/concerns/authorization_core/).

DSL principal — `add_attribute` :

```ruby
def self.add_attribute(name, options = {})
  store_accessor :data, name                     # persiste dans data (jsonb)
  validates name, options[:validation] if options[:validation].present?
  override_primitive_write(name)                 # strip + sanitize HTML (Loofah)
  extra_attributes.push(name)                    # registre exposé au form
end
```

Conventions :

- Tout attribut block est persisté dans la colonne `data` (jsonb) via
  `store_accessor` — pas de migration dédiée.
- Sanitization HTML par défaut sur les attributs texte.
- Validations conditionnelles via `need_complete_validation?(:<step>)` —
  pivot du wizard pas-à-pas (`AuthorizationRequest#need_complete_validation?`).

Catalogue des blocks exposés au registrar :

| Block | Concern | Famille |
| --- | --- | --- |
| `basic_infos` | `AuthorizationExtensions::BasicInfos` | `BLOCK_MODULES` |
| `legal` | `AuthorizationExtensions::CadreJuridique` | `BLOCK_MODULES` |
| `personal_data` | `AuthorizationExtensions::PersonalData` | `BLOCK_MODULES` |
| `cnous_data_extraction_criteria` | `AuthorizationExtensions::CnousDataExtractionCriteria` | `BLOCK_MODULES` |
| `scopes` | DSL `add_scopes` | `BLOCK_PROCS` |
| `contacts` | DSL `contact(kind, ...)` | `BLOCK_PROCS` |

## Pont YAML/DB

Fichiers : [`app/models/authorization_definition.rb`](.../../app/models/authorization_definition.rb),
[`app/models/authorization_request_form.rb`](.../../app/models/authorization_request_form.rb),
[`app/models/static_application_record.rb`](.../../app/models/static_application_record.rb).

Pattern `backend = yaml_records + db_records` :

```ruby
def self.backend
  yaml_records + db_records
end

# Côté AuthorizationDefinition : 1 HabilitationType ──► 1 AuthorizationDefinition
def self.db_records
  return [] unless HabilitationType.table_exists?
  HabilitationType.includes(:data_provider).map { |record| build_from_db_record(record) }
rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
  []
end

# Côté AuthorizationRequestForm : 1 HabilitationType ──has_many──► N FormTemplate ──► N forms
def self.db_records
  return [] unless FormTemplate.table_exists?
  FormTemplate.includes(:habilitation_type).filter_map { |t| build_form_from_template(t) }
rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
  []
end
```

`FormTemplate` (table `form_templates`, FK `habilitation_type_id`) intercale entre
`HabilitationType` et `AuthorizationRequestForm` : un HT a 1+ FormTemplate dont
**exactement 1** marqué `default: true` (invariant garanti par les validations
`only_one_default_per_habilitation_type` + `ht_keeps_at_least_one_default` +
`ensure_not_last_default`, plus le callback
`HabilitationType#after_create :ensure_default_form_template!`). Le slug du
FormTemplate sert d'`uid` côté façade ARF. Cf. [DP-1718](https://linear.app/pole-api/issue/DP-1718).

**Filet DB : index partiel unique.** L'unicité du default est aussi gravée dans
le schéma — `index_one_default_form_template_per_habilitation_type` sur
`habilitation_type_id` `WHERE "default"` (le mot `default` est réservé, d'où le
quoting). Les validations donnent les beaux messages ; l'index protège des
contournements (`update_column`, `insert_all`) et des courses concurrentes.
⚠️ **PR2/PR3 — opération « changer le default »** : promouvoir un template alors
qu'un autre est déjà default doit **rétrograder l'ancien avant de promouvoir le
nouveau**, dans une transaction (sinon deux `default: true` transitoires →
`RecordNotUnique`). Alternative si l'ordre devient gênant : passer la contrainte
en `DEFERRABLE INITIALLY DEFERRED` (SQL brut, la vérif se fait au `COMMIT`).

**Slug du template default = slug du HT (pas de suffixe).** Le default auto-créé
reprend tel quel le slug du `HabilitationType` (`form_templates.create!(slug:,
default: true)`), il n'encode **pas** son statut (`-default` proscrit). L'uid est
un identifiant **public, persisté et immuable** : URLs « commencer une demande »
transmises aux partenaires, `form_uid` POSTé via l'API v1, colonne
`authorization_request.form_uid`, filtres export DGFIP. Encoder un état mutable
dans l'uid casserait tout cela le jour où le default change de template (la
désignation `default` est une **colonne booléenne** — `default_form` la lit via
`available_forms.find(&:default)`, jamais le slug). Bonus : réutiliser le slug du
HT préserve l'uid d'avant DP-1718 (`uid: record.slug`), donc les demandes
existantes continuent de résoudre leur form sans data-migration sur `form_uid`.
Les templates **non-default** reçoivent des slugs explicites et stables, eux aussi
immuables une fois diffusés.

**Cascade éditoriale HT → FT default**. Le FormTemplate auto-créé ne porte que
`slug` + `default: true` ; les champs éditoriaux (`name`, `description`,
`introduction`, `steps`) restent **vides** côté template et sont résolus à la
volée dans `build_form_from_template` via `template.<champ>.presence || ht.<champ>`.
Conséquence : éditer le HT propage automatiquement aux ARF qui en dépendent,
tant qu'aucun override explicite n'est posé sur le template. Quand l'UI admin
FormTemplate arrivera (DP-1718 PR2/PR3), renseigner un champ sur le template le
fera prendre le pas sur le HT.

**Invalidation du cache ARF**. `FormTemplate.after_commit :reset_arf_cache` et
`HabilitationType.after_commit :reset_static_caches` (post-commit, pas
`after_save`) bumpent le compteur Redis **après** que la transaction soit
committée — autrement, un autre process pourrait reconstruire `@all` depuis
une vue pré-commit (race).

`StaticApplicationRecord` mémorise le backend dans `@all` et invalide via un
compteur Redis (`Kredis.counter(redis_cache_key).increment`). Coordination
indispensable en multi-process (Puma + Sidekiq) : sans bump Redis, un save
sur le worker A laisserait le worker B servir une vue stale.

Filiation STI : une demande pour un type DB est instance de
`AuthorizationRequest::<Uid>Dyn`, et `AuthorizationRequest#definition`
résout via `AuthorizationDefinition.find(to_s.demodulize.underscore)` —
le find aboutit indistinctement côté YAML ou DB.

## Limitations connues

- **`custom_labels` (jsonb)** : présent en DB et factory, aucune lecture
  dans le code à ce jour. Surface réservée pour personnalisation éditoriale.
- **Concerns existants non exposés au registrar** (présents dans
  `authorization_extensions/` mais absents de `BLOCK_MODULES`) :
  `france_connect`, `france_connect_eidas`, `france_connect_embedded_fields`,
  `gdpr_contacts`, `modalities`, `operational_acceptance`,
  `safety_certification`, `technical_team`, `volumetrie`. Procédure
  d'exposition → [ajout_block_dynamique.md](./ajout_block_dynamique.md).
- **CRUD admin de `FormTemplate`** : pas encore exposée en UI (DP-1718 PR 1).
  La création/édition se fait en `rails c` ; le default est auto-créé à la
  création d'un `HabilitationType` (callback `ensure_default_form_template!`).
  Les HT déjà en base sont dotés de leur default par la migration de données
  `BackfillDefaultFormTemplates` (SQL idempotent, slug = slug du HT), qui
  s'applique automatiquement à chaque environnement et en local.

## Tableau récap « où vit quoi »

| Sujet | Fichier |
| --- | --- |
| Modèle DB | [`app/models/habilitation_type.rb`](.../../app/models/habilitation_type.rb) |
| Modèle DB templates de form | [`app/models/form_template.rb`](.../../app/models/form_template.rb) |
| Migration création | [`db/migrate/20260225111739_create_habilitation_types.rb`](../db/migrate/20260225111739_create_habilitation_types.rb) |
| Migration suffixe `-dyn` | [`db/migrate/20260401152848_add_dyn_suffix_to_habilitation_type_slugs.rb`](../db/migrate/20260401152848_add_dyn_suffix_to_habilitation_type_slugs.rb) |
| Migration form_templates | [`db/migrate/20260513000001_create_form_templates.rb`](../db/migrate/20260513000001_create_form_templates.rb) |
| Migration index 1 default/HT | [`db/migrate/20260608193914_enforce_single_default_form_template_per_habilitation_type.rb`](../db/migrate/20260608193914_enforce_single_default_form_template_per_habilitation_type.rb) |
| Migration backfill defaults | [`db/migrate/20260615100802_backfill_default_form_templates.rb`](../db/migrate/20260615100802_backfill_default_form_templates.rb) |
| Registrar | [`app/services/dynamic_authorization_request_registrar.rb`](.../../app/services/dynamic_authorization_request_registrar.rb) |
| Initializer Rails | [`config/initializers/dynamic_authorization_types.rb`](../../config/initializers/dynamic_authorization_types.rb) |
| Concerns blocks | [`app/models/concerns/authorization_extensions/`](.../../app/models/concerns/authorization_extensions/) |
| DSL réutilisable | [`app/models/concerns/authorization_core/`](.../../app/models/concerns/authorization_core/) |
| Cache / invalidation Redis | [`app/models/static_application_record.rb`](.../../app/models/static_application_record.rb) |
| Pont YAML/DB définitions | [`app/models/authorization_definition.rb`](.../../app/models/authorization_definition.rb) |
| Pont YAML/DB forms | [`app/models/authorization_request_form.rb`](.../../app/models/authorization_request_form.rb) |
| Consommateur STI | [`app/models/authorization_request.rb`](.../../app/models/authorization_request.rb) (`definition`, `need_complete_validation?`) |
| Notifications utilisateur | [`app/models/concerns/notifications_settings.rb`](.../../app/models/concerns/notifications_settings.rb) |
| Templates de messages | [`app/models/message_template.rb`](.../../app/models/message_template.rb) |
| Spec modèle | [`spec/models/habilitation_type_spec.rb`](../../spec/models/habilitation_type_spec.rb) |
| Spec registrar | [`spec/services/dynamic_authorization_request_registrar_spec.rb`](../../spec/services/dynamic_authorization_request_registrar_spec.rb) |

## Points d'attention

- **Cache Redis-coordonné** : toute écriture en DB qui contourne les
  callbacks (`update_columns`, SQL direct) laisse les workers servir une
  vue stale. Réinvalider à la main avec `AuthorizationDefinition.reset!`
  puis `AuthorizationRequestForm.reset!`.
- **Slug figé après création** : `should_generate_new_friendly_id?` ne
  renvoie `true` qu'au premier save. Tout renommage de slug DB doit
  reproduire les 5 propagations de la migration `20260401152848`
  (`habilitation_types.slug`, `*.type` STI, `*.form_uid`, `users.roles`,
  `users.settings.instruction_*`).
- **Idempotence du registrar** : `remove_const` avant `const_set` permet
  de rejouer le registrar à volonté. Une ré-inscription remplace bien la
  constante (les anciennes instances en mémoire deviennent orphelines).
- **Gating BLOCK_ORDER vs BLOCK_MODULES** : un block peut être exposé au
  registrar (donc enregistrable) sans être dans `BLOCK_ORDER` (donc
  inactif côté wizard). Pattern `cnous_data_extraction_criteria` — voir
  [ajout_block_dynamique.md](./ajout_block_dynamique.md).
- **Couplage `data_provider` (FK SQL)** : un type DB appartient toujours à
  un `DataProvider`. Le couplage à un `ServiceProvider` (YAML-backed
  `StaticApplicationRecord`) se fait au niveau du `FormTemplate` via la
  colonne string `service_provider_id`, résolue côté façade.