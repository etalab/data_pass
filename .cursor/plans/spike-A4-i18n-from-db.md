---
shaping: true
---

# A4 Spike: Custom labels from DB for the legal block

## Context

The legal block has customizable labels (nature field label/hint, justificatif
title). Currently, all form wordings go through a single resolution method
(`wording_for`) in the form builder, with a 3-level I18n cascade. For DB-based
types, there are no YAML entries, so everything falls through to the defaults.
We need a way to store custom labels in DB and inject them into this cascade.

## Goal

Identify the simplest mechanism to override specific I18n keys from DB while
keeping the existing cascade intact for everything else.

## Questions & Answers

### A4-Q1: How does the current I18n resolution work?

All form labels, hints, and wordings flow through one method in
`AuthorizationRequestFormBuilder`:

```ruby
def wording_for(key, opts = {})
  opts[:default] = nil

  I18n.t("authorization_request_forms.#{@object.form.uid.underscore}.#{key}", **opts) ||
    I18n.t("authorization_request_forms.#{@object.model_name.element}.#{key}", **opts) ||
    I18n.t("authorization_request_forms.default.#{key}", **opts)
end
```

Three levels:
1. **Form-specific**: `authorization_request_forms.<form_uid>.<key>`
2. **Definition-specific**: `authorization_request_forms.<model_element>.<key>`
3. **Default**: `authorization_request_forms.default.<key>`

Field labels and hints also go through `wording_for`:

```ruby
def label_value(attribute)
  wording_for("#{attribute}.label").try(:html_safe) || super
end

def hint_for(attribute)
  wording_for("#{attribute}.hint") || super
end
```

**Key insight: `wording_for` is the single bottleneck.** Changing one method
covers all form wordings.

### A4-Q2: What specific keys does the legal block use?

From the legal block template (`blocks/default/_legal.html.erb`), these keys
are resolved via `wording_for`:

| Key | Default value | Used in |
|-----|--------------|---------|
| `legal.nature.title` | *(none at default level — optional)* | Section title above nature field |
| `legal.nature.description` | *(none at default level — optional)* | Section description |
| `legal.justificatif.title` | "Les justificatifs de votre cadre juridique" | Section title above document/URL |
| `legal.justificatif.description` | "Vous pouvez choisir d'indiquer une URL ou d'ajouter un fichier" | Section description |
| `legal.cadre_juridique_url.title` | *(none at default level)* | Title above URL field |
| `cadre_juridique_nature.label` | "Précisez la nature et les références du texte vous autorisant à traiter les données" | Field label |
| `cadre_juridique_nature.hint` | "loi, décret, arrêté, délibération, etc." | Field hint |
| `cadre_juridique_document.label` | "Ajoutez votre document" | Field label |
| `cadre_juridique_document.hint` | "Taille maximale: 10 Mo. Formats supportés: pdf" | Field hint |
| `cadre_juridique_url.label` | "URL du texte relatif au traitement" | Field label |

The first three are the ones the user specifically wants customizable.
The template wraps the optional ones in `if` guards, so missing keys are safe.

### A4-Q3: What's the recommended approach?

**Add a "level 0" check in `wording_for` that looks for DB-stored custom
labels before the I18n cascade.**

```ruby
def wording_for(key, opts = {})
  opts[:default] = nil

  custom_label_for(key) ||
    I18n.t("authorization_request_forms.#{@object.form.uid.underscore}.#{key}", **opts) ||
    I18n.t("authorization_request_forms.#{@object.model_name.element}.#{key}", **opts) ||
    I18n.t("authorization_request_forms.default.#{key}", **opts)
end

private

def custom_label_for(key)
  definition = @object.definition
  return nil unless definition.respond_to?(:custom_labels)

  labels = definition.custom_labels
  return nil if labels.blank?

  labels.dig(*key.to_s.split('.'))
end
```

**Why this works:**
- Changes exactly 1 method + adds 1 private helper
- YAML-based types don't have `custom_labels` → returns nil → existing cascade
  continues unchanged
- DB-based types with no custom labels → returns nil → falls through to defaults
- DB-based types with custom labels → returns the override → stops cascade
- `label_value` and `hint_for` both call `wording_for` → automatically covered

### A4-Q4: What does the DB storage look like?

A `custom_labels` jsonb column on `authorization_definition_records`:

```json
{
  "cadre_juridique_nature": {
    "label": "Précisez la nature et les références du texte...",
    "hint": "loi, décret, arrêté, délibération, etc."
  },
  "legal": {
    "justificatif": {
      "title": "Les justificatifs de votre cadre juridique",
      "description": "Vous pouvez choisir d'indiquer une URL ou d'ajouter un fichier"
    }
  }
}
```

The structure mirrors the I18n key path: `wording_for('legal.justificatif.title')`
→ `custom_labels.dig('legal', 'justificatif', 'title')`.

### A4-Q5: How does the AuthorizationDefinition object expose this?

When `build_from_record` creates an `AuthorizationDefinition` from a DB
record (see A1 spike), it needs to include `custom_labels`. We add it as an
attribute:

```ruby
class AuthorizationDefinition < StaticApplicationRecord
  attr_accessor :custom_labels
  # ... existing attrs ...
end
```

For YAML-based definitions, `custom_labels` is nil (never set).
For DB-based definitions, `build_from_record` sets it from the DB column.

### A4-Q6: What about the summary view?

The summary view (`authorization_requests/blocks/default/_legal.html.erb`)
uses both `f.label_value(:cadre_juridique_nature)` (goes through `wording_for`
→ covered) and direct `t()` calls for generic labels like "Lien du texte" /
"Document". These generic labels don't need customization.

### A4-Q7: What does the admin UI look like for label customization?

In the admin builder, when the legal block is selected, show text fields for
each customizable label, pre-filled with the I18n defaults:

```
┌─ Legal block labels ──────────────────────────────┐
│                                                     │
│ Nature field label:                                 │
│ [Précisez la nature et les références du texte...] │
│                                                     │
│ Nature field hint:                                  │
│ [loi, décret, arrêté, délibération, etc.]          │
│                                                     │
│ Justificatif section title:                         │
│ [Les justificatifs de votre cadre juridique]       │
│                                                     │
└─────────────────────────────────────────────────────┘
```

On save, if a label equals the default, it can be stored or omitted (both
work since `wording_for` falls through). Storing it is simpler and makes
the admin UI stateless.

## Summary

| Question | Answer |
|----------|--------|
| Need custom I18n backend? | **No** — one method change in form builder |
| Consumer changes? | **None** — `wording_for` cascade is extended, not replaced |
| Storage? | **jsonb column** `custom_labels` on `authorization_definition_records` |
| YAML types affected? | **No** — `custom_labels` is nil, cascade continues |
| Extensible? | **Yes** — adding more customizable labels = more keys in jsonb |
| Risk level? | **Low** — one method change, additive, no side effects |

## Acceptance

Spike is complete. We can describe the concrete steps:

1. Add `custom_labels` jsonb column to `authorization_definition_records`
2. Add `custom_labels` attr_accessor to `AuthorizationDefinition`
3. Set it in `build_from_record` (nil for YAML types)
4. Add `custom_label_for` private method to `AuthorizationRequestFormBuilder`
5. Prepend it as level 0 in `wording_for`
6. Admin UI: text fields for customizable labels, pre-filled with defaults
