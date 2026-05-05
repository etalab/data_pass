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

def self.db_records
  return [] unless HabilitationType.table_exists?
  HabilitationType.includes(:data_provider).map { |record| build_from_db_record(record) }
rescue ActiveRecord::NoDatabaseError, ActiveRecord::StatementInvalid
  []
end
```

`StaticApplicationRecord` mémorise le backend dans `@all` et invalide via un
compteur Redis (`Kredis.counter(redis_cache_key).increment`). Coordination
indispensable en multi-process (Puma + Sidekiq) : sans bump Redis, un save
sur le worker A laisserait le worker B servir une vue stale.

Filiation STI : une demande pour un type DB est instance de
`AuthorizationRequest::<Uid>Dyn`, et `AuthorizationRequest#definition`
résout via `AuthorizationDefinition.find(to_s.demodulize.underscore)` —
le find aboutit indistinctement côté YAML ou DB.

## Limitations connues

- **`use_case` et `initialize_with` non disponibles côté DB** :
  `build_form_from_habilitation_type` passe `use_case: nil` et n'expose pas
  `initialize_with`. Le préremplissage par cas d'usage reste YAML-only.
- **`custom_labels` (jsonb)** : présent en DB et factory, aucune lecture
  dans le code à ce jour. Surface réservée pour personnalisation éditoriale.
- **Concerns existants non exposés au registrar** (présents dans
  `authorization_extensions/` mais absents de `BLOCK_MODULES`) :
  `france_connect`, `france_connect_eidas`, `france_connect_embedded_fields`,
  `gdpr_contacts`, `modalities`, `operational_acceptance`,
  `safety_certification`, `technical_team`, `volumetrie`. Procédure
  d'exposition → [ajout_block_dynamique.md](./ajout_block_dynamique.md).
- **`static_blocks` non porté côté DB** : `build_form_from_habilitation_type`
  passe `static_blocks: []`.

## Tableau récap « où vit quoi »

| Sujet | Fichier |
| --- | --- |
| Modèle DB | [`app/models/habilitation_type.rb`](.../../app/models/habilitation_type.rb) |
| Migration création | [`db/migrate/20260225111739_create_habilitation_types.rb`](../db/migrate/20260225111739_create_habilitation_types.rb) |
| Migration suffixe `-dyn` | [`db/migrate/20260401152848_add_dyn_suffix_to_habilitation_type_slugs.rb`](../db/migrate/20260401152848_add_dyn_suffix_to_habilitation_type_slugs.rb) |
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
  un `DataProvider`. Aucun couplage à un `ServiceProvider` côté DB.