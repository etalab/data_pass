---
shaping: true
---

# A1 Spike: HybridApplicationRecord — Making DB records transparent

## Context

`AuthorizationDefinition` and `AuthorizationRequestForm` currently inherit from
`StaticApplicationRecord`, which loads all records from YAML and serves them
in-memory. We need DB-based records to work alongside YAML-based ones
transparently, so that all consumers (controllers, views, other models) don't
need to change.

## Goal

Identify how to extend the current system so `AuthorizationDefinition.find`,
`.all`, `.where` return both YAML and DB records, with no consumer changes.

## Questions & Answers

### A1-Q1: What is the full StaticApplicationRecord API surface?

**Class methods** (used by consumers):
- `find(id)` — find by ID, raises `EntryNotFound` if missing
- `all` — returns all records, **cached** with `@all ||= backend`
- `where(conditions)` — filters `all` by conditions hash
- `exists?(conditions)` — checks if any match
- `find_by(params)` — first match from `where`
- `unscoped { block }` — no-op (yields block)

**Instance methods:**
- `id` — unique identifier (abstract in base, implemented per subclass)
- `[](attr)` — delegates to `public_send`
- `==(other)` — compares by `id`

**Key property:** `all` is the single data source. Every query method (`find`,
`where`, `exists?`, `find_by`) goes through `all`. This means we only need to
change `all` (or `backend`) to add DB records.

### A1-Q2: How to make a DB record look identical to a YAML record?

**Finding: We don't need a new base class.** The cleanest approach is to override
`backend` in `AuthorizationDefinition` to merge both sources.

The existing `build(uid, hash)` method already constructs an
`AuthorizationDefinition` instance from a hash. We can add a `build_from_record`
method that constructs the same object from a DB record:

```ruby
class AuthorizationDefinition < StaticApplicationRecord
  def self.backend
    yaml_records + db_records
  end

  def self.yaml_records
    AuthorizationDefinitionConfigurations.instance.all.map do |uid, hash|
      build(uid, hash)
    end
  end

  def self.db_records
    AuthorizationDefinitionRecord.all.map do |record|
      build_from_record(record)
    end
  end

  def self.build_from_record(record)
    new(
      id: record.uid,
      name: record.name,
      description: record.description,
      # ... map all fields ...
      scopes: record.scopes_data.map { |s| Scope.new(s) },
      blocks: record.blocks,
      features: record.features,
    )
  end
end
```

**Why this works:**
- `all` returns a list of `AuthorizationDefinition` objects regardless of source
- `find`, `where`, `exists?`, `find_by` all go through `all` — no changes needed
- Every consumer sees the same interface
- YAML records and DB records are indistinguishable after construction

**Same approach applies to `AuthorizationRequestForm`.**

### A1-Q3: How to handle cache invalidation?

`StaticApplicationRecord.all` caches with `@all ||= backend`. YAML records
never change at runtime, so this is fine today.

When a new DB-based type is created:
- `@all` must be reset so the next call to `all` re-fetches from both sources
- Add a `reset!` class method:

```ruby
class StaticApplicationRecord
  module ClassMethods
    def reset!
      @all = nil
    end
  end
end
```

After creating a type:
```ruby
AuthorizationDefinition.reset!
AuthorizationRequestForm.reset!
```

**Caveat for multi-process servers (Puma with workers):** Other worker processes
won't see the new type until their cache is invalidated. Options:
- Accept that other workers see it on next restart (simplest for V1)
- Use `Rails.application.config.to_prepare` to reload on each request in dev
- In production, this is usually OK since new types are rare events

### A1-Q4: What about AuthorizationDefinition-specific methods?

Several methods on `AuthorizationDefinition` need to work for DB-based records:

| Method | Works as-is? | Notes |
|--------|:---:|-------|
| `authorization_request_class` | Yes | Uses `AuthorizationRequest.const_get(id.classify)` — works if dynamic class is registered (see A3 spike) |
| `provider` | Yes | Uses `DataProvider.friendly.find(@provider_slug)` — DB-based records set the same field |
| `available_forms` | Yes | Queries `AuthorizationRequestForm.where(authorization_request_class:)` — works through `all` |
| `feature?(name)` | Yes | Reads from `features` hash |
| `editors` | Yes | Delegates through `available_forms` |
| `instructors` / `reporters` | Yes | Uses `User.instructor_for(id)` — works with any string ID |
| `need_homologation?` | Yes | Hardcoded to specific IDs — DB types return false (correct) |
| `france_connect?` | Yes | Hardcoded to `france_connect` — DB types return false (correct) |
| `stage` | N/A | Out of scope — DB types won't have stages |

**All methods work as-is.** The object structure is identical regardless of
source.

### A1-Q5: What about name collisions between YAML and DB?

If someone creates a DB-based type with an ID that already exists in YAML,
both would appear in `all`. Solutions:
- Validate uniqueness on creation (check both YAML IDs and existing DB IDs)
- YAML takes precedence (current order: `yaml_records + db_records`)

**Recommendation:** Validate on creation. The admin UI should check
`AuthorizationDefinition.exists?(id: proposed_uid)` before saving.

## Summary

| Question | Answer |
|----------|--------|
| Need new base class? | **No** — override `backend` in AuthorizationDefinition and AuthorizationRequestForm |
| Consumer changes needed? | **None** — same API, same objects |
| DB table needed? | **Yes** — `authorization_definition_records` + `authorization_request_form_records` |
| Cache invalidation? | **reset! method** — clear `@all` after creation |
| Risk level? | **Low** — minimal changes to existing code, purely additive |

## Acceptance

Spike is complete. We can describe the concrete steps to make DB-based
definitions transparent alongside YAML-based ones:

1. Create `AuthorizationDefinitionRecord` model + migration
2. Create `AuthorizationRequestFormRecord` model + migration
3. Override `backend` in `AuthorizationDefinition` to merge YAML + DB
4. Override `backend` in `AuthorizationRequestForm` to merge YAML + DB
5. Add `build_from_record` class method to both
6. Add `reset!` to `StaticApplicationRecord`
7. Validate UID uniqueness across both sources on creation
