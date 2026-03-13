---
shaping: true
---

# A3 Spike: Dynamic class generation for DB-based authorization types

## Context

Each authorization type currently has a dedicated Ruby class
(`AuthorizationRequest::APIEntreprise`, etc.) that inherits from
`AuthorizationRequest` and includes the right concerns (blocks). For DB-based
types, we need to dynamically create these classes at runtime based on the
stored block configuration.

## Goal

Identify how dynamic class generation works with Rails STI, development mode
reloading, and the existing concern inclusion pattern.

## Questions & Answers

### A3-Q1: Does Rails STI handle dynamically-created classes?

**Yes.** Rails resolves STI types by calling `type_column.constantize`.
For a record with `type = "AuthorizationRequest::MyNewType"`, Rails calls
`"AuthorizationRequest::MyNewType".constantize`.

This works if the constant exists. Registering it with:

```ruby
klass = Class.new(AuthorizationRequest)
AuthorizationRequest.const_set("MyNewType", klass)
```

...makes `AuthorizationRequest::MyNewType` a valid constant that
`constantize` will find.

**Verified:** Ruby's `const_set` automatically assigns the `name` to the
class. After `const_set`, `klass.name` returns
`"AuthorizationRequest::MyNewType"`, and `klass.to_s.demodulize.underscore`
returns `"my_new_type"` — which is the expected definition ID.

### A3-Q2: How does `definition` resolution work with dynamic classes?

The current mechanism:

```ruby
def self.definition
  @definition ||= AuthorizationDefinition.find(to_s.demodulize.underscore)
end
```

For `AuthorizationRequest::MyNewType`:
- `to_s` → `"AuthorizationRequest::MyNewType"`
- `.demodulize` → `"MyNewType"`
- `.underscore` → `"my_new_type"`
- `AuthorizationDefinition.find("my_new_type")` → finds the DB-based definition

**This works out of the box** as long as:
- The definition ID in DB matches the class name convention
- `AuthorizationDefinition.all` includes DB records (solved by A1)

**Naming convention important:** The Rails inflection system is used.
`"api_entreprise".classify` → `"APIEntreprise"` (because of `inflect.acronym 'API'`).
For DB-based types, we should:
- Store a `uid` (snake_case) as the definition ID
- The dynamic class name is `uid.classify`
- Use the same `classify` for `const_set`

Simple names like `my_new_type` → `MyNewType` work without issues. Names
containing configured acronyms (API, DGFIP, etc.) also work correctly.

### A3-Q3: Can concerns be included dynamically on a subclass?

**Yes.** All the block concerns (`BasicInfos`, `CadreJuridique`, etc.) use
`class_eval` and `class instance variables` internally. They work correctly
on dynamically-created subclasses.

Concrete mechanism:

```ruby
def self.build_dynamic_class(definition_record)
  klass = Class.new(AuthorizationRequest)

  if definition_record.blocks.include?('basic_infos')
    klass.include(AuthorizationExtensions::BasicInfos)
  end

  if definition_record.blocks.include?('legal')
    klass.include(AuthorizationExtensions::CadreJuridique)
  end

  if definition_record.blocks.include?('personal_data')
    klass.include(AuthorizationExtensions::PersonalData)
  end

  if definition_record.blocks.include?('contacts')
    definition_record.contact_types.each do |contact_type|
      klass.contact(
        contact_type.to_sym,
        validation_condition: ->(record) { record.need_complete_validation?(:contacts) }
      )
    end
  end

  if definition_record.blocks.include?('scopes')
    klass.add_scopes(validation: {
      presence: true, if: -> { need_complete_validation?(:scopes) }
    })
  end

  klass
end
```

**Why it works:**
- `klass.include(SomeConcern)` triggers the `included` block on the subclass
- `AuthorizationCore::Contacts#contact` is a class method inherited from
  `AuthorizationRequest` — callable on any subclass
- Class instance variables (`@contacts`, `@extra_attributes`, `@scopes_enabled`)
  are per-class in Ruby, so each dynamic subclass gets its own state
- `store_accessor :data, name` and `validates` work on the subclass's own
  column (inherited `data` jsonb from `authorization_requests` table)

### A3-Q4: What about development mode reloading?

In development, Rails reloads code on each request (Zeitwerk). When
`AuthorizationRequest` is reloaded, all its constants (including dynamic
ones) are cleared.

**Solution:** Use `Rails.application.config.to_prepare`:

```ruby
# config/initializers/dynamic_authorization_types.rb
Rails.application.config.to_prepare do
  AuthorizationDefinitionRecord.find_each do |record|
    DynamicAuthorizationTypeRegistrar.register(record)
  end
end
```

`to_prepare` runs:
- On every request in development (after code reload)
- Once in production (at boot)

This ensures dynamic classes are always available.

**Edge case:** The `to_prepare` block runs after Zeitwerk autoloads, so
`AuthorizationRequest`, `AuthorizationExtensions::BasicInfos`, etc. are all
available at this point.

**Edge case:** In production with Puma workers, `to_prepare` runs once per
worker on fork. New types created after boot need runtime registration (see
A3-Q5).

### A3-Q5: How to handle runtime registration (admin creates a type)?

When the admin creates a new type through the UI:

1. Save `AuthorizationDefinitionRecord` and `AuthorizationRequestFormRecord`
2. Build and register the dynamic class immediately:

```ruby
klass = DynamicAuthorizationTypeRegistrar.register(record)
```

3. Reset caches:

```ruby
AuthorizationDefinition.reset!
AuthorizationRequestForm.reset!
```

4. The type is immediately usable in the current process.

**Other Puma workers:** They won't see the new class until:
- Next restart (production deploys)
- Or we add a simple mechanism: check for new DB records periodically or on
  `to_prepare` (development handles this automatically)

**For V1, this is acceptable:** New type creation is a rare admin action.
The admin who creates it sees it immediately. Other users see it after
the next deploy or server restart.

### A3-Q6: What about `const_set` conflicts?

If the admin restarts the server and the dynamic class is re-registered,
`const_set` with an already-existing name will overwrite silently. This is
fine — the class is rebuilt from the same DB config.

If a DB-based type has the same name as a YAML-based type's class, we'd
have a conflict. **Same solution as A1:** validate uniqueness on creation.

### A3-Q7: What does the registration service look like?

```ruby
class DynamicAuthorizationTypeRegistrar
  def self.register(definition_record)
    class_name = definition_record.uid.classify
    klass = build_class(definition_record)
    AuthorizationRequest.const_set(class_name, klass)
    klass
  end

  def self.build_class(definition_record)
    klass = Class.new(AuthorizationRequest)
    apply_blocks(klass, definition_record)
    klass
  end

  def self.apply_blocks(klass, definition_record)
    # Include concerns based on block config
    # (as shown in A3-Q3)
  end
end
```

## Summary

| Question | Answer |
|----------|--------|
| Rails STI with dynamic classes? | **Works** — `const_set` makes `constantize` resolve correctly |
| `definition` resolution? | **Works** — `to_s.demodulize.underscore` produces the expected definition ID |
| Dynamic concern inclusion? | **Works** — concerns use `class_eval` and class instance variables, compatible with `Class.new` subclasses |
| Development reloading? | **Solved** — `to_prepare` re-registers dynamic classes on each reload |
| Runtime registration? | **Solved** — register immediately + reset caches; other workers pick up on restart |
| Risk level? | **Medium** — relies on Ruby metaprogramming patterns that are well-established but need thorough testing |

## Acceptance

Spike is complete. We can describe the concrete steps to implement dynamic
class generation:

1. Create `DynamicAuthorizationTypeRegistrar` service
2. `register(record)` builds class, includes concerns, registers constant
3. `to_prepare` initializer calls `register` for all DB-based definitions
4. Admin creation flow calls `register` + `reset!` after saving
5. Block-to-concern mapping is a simple hash lookup
6. Contact types are stored as an array in the definition record and
   iterated during class building
7. Class names follow `uid.classify` convention (same inflection rules as
   existing types)
