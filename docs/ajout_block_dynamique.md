# Ajouter un block à une habilitation dynamique

> Ce guide couvre les habilitations créées via l'UI d'admin (système DB,
> slug suffixé `-dyn`). Pour les types YAML legacy, voir
> [ajout_nouveau_bloc_de_formulaire.md](./ajout_nouveau_bloc_de_formulaire.md).
> Pour les mécanismes profonds (registrar, cache Redis, STI), voir
> [habilitation_type_dynamique.md](./habilitation_type_dynamique.md).

Exemple de référence vivant — le block `cnous_data_extraction_criteria` :

- [`752ff8b2`](https://github.com/etalab/data_pass/commit/752ff8b2) — Introduce CNOUS data extraction criteria block (concern + registrar + gating volontaire)

## Choisir le type de block

Question décisive : **« le block lit-il un attribut du record
(`scopes`, `contact_types`, …) pour se configurer ? »**

- Oui → `BLOCK_PROCS` (lambda `(klass, record) -> { … }`).
- Non → `BLOCK_MODULES` (concern à inclure tel quel).

## Étapes

### A. Créer le concern

`app/models/concerns/authorization_extensions/<name>.rb` :

```ruby
module AuthorizationExtensions::<Name>
  extend ActiveSupport::Concern

  included do
    %i[attr1 attr2].each do |attr|
      add_attribute attr
      validates attr,
        presence: true,
        if: -> { need_complete_validation?(:<name>) }
    end
  end
end
```

Règles :

- Toujours utiliser `add_attribute` (jamais `attr_accessor`) — la valeur
  est persistée dans `data` (jsonb), sanitizée HTML, exposée dans
  `extra_attributes`.
- Conditionner systématiquement les validations par
  `need_complete_validation?(:<name>)` — sans ce garde-fou, impossible de
  sauver un brouillon.
- Pour les types `:array` ou `:boolean` : `add_attribute :foo, type: :array`.
- Préfixer les attributs par le nom du block (`cadre_juridique_url`,
  `duree_conservation_donnees_caractere_personnel`) pour éviter les
  collisions entre concerns.

### B. Enregistrer dans le registrar

Modifier [`app/services/dynamic_authorization_request_registrar.rb`](../app/services/dynamic_authorization_request_registrar.rb).

Block simple → ajouter une entrée dans `BLOCK_MODULES` :

```ruby
BLOCK_MODULES = {
  'basic_infos'   => AuthorizationExtensions::BasicInfos,
  'legal'         => AuthorizationExtensions::CadreJuridique,
  'personal_data' => AuthorizationExtensions::PersonalData,
  'cnous_data_extraction_criteria' => AuthorizationExtensions::CnousDataExtractionCriteria,
  '<name>'                         => AuthorizationExtensions::<Name>,
}.freeze
```

Block dynamique → ajouter une lambda dans `BLOCK_PROCS` :

```ruby
'<name>' => lambda { |klass, record|
  record.<some_attribute>.each do |item|
    klass.add_attribute "<name>_#{item}",
      validation: { presence: true, if: -> { need_complete_validation?(:<name>) } }
  end
},
```

### C. `BLOCK_ORDER` (ou gating volontaire)

Modifier [`app/models/habilitation_type.rb`](../app/models/habilitation_type.rb) :

```ruby
BLOCK_ORDER = %w[basic_infos legal personal_data scopes contacts].freeze
```

Pattern de gating : un block peut être présent dans `BLOCK_MODULES` **sans**
être dans `BLOCK_ORDER`. C'est exactement ce que fait le commit `752ff8b2`
pour `cnous_data_extraction_criteria` : code backend prêt, vues non livrées,
donc le block est exclu de l'ordre du wizard. À documenter explicitement dans
la PR si vous prenez ce chemin.

### D. Créer les vues

Trois partials à fournir, basés sur les helpers DSFR :

| Vue | Chemin |
| --- | --- |
| Form (remplissage) | `app/views/authorization_request_forms/blocks/default/_<name>.html.erb` |
| Step du wizard | `app/views/authorization_request_forms/build/<name>.html.erb` |
| Summary (lecture) | `app/views/authorization_requests/blocks/default/_<name>.html.erb` |

Garder chaque champ derrière `respond_to?(:attr)` pour permettre la
réutilisation du partial sur un type qui n'a pas le block :

```erb
<% if @authorization_request.respond_to?(:intitule) %>
  <%= f.dsfr_text_field :intitule %>
<% end %>
```

Surcharge par définition : créer le partial sous
`app/views/.../blocks/<definition_uid>/_<name>.html.erb`. Routage automatique
via `render_custom_form_or_default` et `render_custom_block_or_default`.

### E. i18n

Trois fichiers à mettre à jour :

- `config/locales/fr.yml` — nom de la step pour wicked.
- `config/locales/authorization_request_forms.fr.yml` — titre et description
  du block dans le wizard.
- `config/locales/activerecord.fr.yml` — libellés des attributs et messages
  d'erreur.

### F. Tests

Spec du registrar (obligatoire) — [`spec/services/dynamic_authorization_request_registrar_spec.rb`](../spec/services/dynamic_authorization_request_registrar_spec.rb).
Ajouter un `context 'with <name> block'` qui :

1. vérifie que `extra_attributes` contient les bons attributs ;
2. teste les validations sur `valid?(:submit)` (cas vide, cas complet, cas
   limite).

Template à copier : le bloc `'with cnous_data_extraction_criteria block'` du même spec.

Factory — [`spec/factories/habilitation_types.rb`](../spec/factories/habilitation_types.rb) :
ajouter un trait `with_<name>` si le block doit être testé dans plusieurs
specs.

Test e2e cucumber — `features/habilitations/<provider>/<form>.feature` avec
une step `Quand("Je renseigne <bloc>")` dans `features/step_definitions/`.

## Pièges courants

- **Validation déclenchée trop tôt** — `validates ... presence: true` sans
  le garde `if: -> { need_complete_validation?(:<step>) }`. Symptôme :
  impossible de sauver un brouillon. Solution : conditionner
  systématiquement les validations.
- **Cache statique non invalidé** — `update_columns` ou SQL direct
  contourne `after_save :reset_static_caches`. Symptôme : l'app continue
  à servir l'ancienne définition. Solution : sauver via les callbacks ou
  appeler à la main `AuthorizationDefinition.reset!` puis
  `AuthorizationRequestForm.reset!`.
- **Block dans `BLOCK_ORDER` sans vue livrée** — le wizard plante ou
  affiche une page vide quand un utilisateur arrive sur la step. Solution :
  reproduire le pattern `cnous_data_extraction_criteria` (commit `752ff8b2`) — laisser
  le block hors de `BLOCK_ORDER` tant que les vues ne sont pas en prod.
- **Slug en collision avec un type YAML** — mitigation auto par le suffixe
  `-dyn` et la validation `slug_not_taken_by_yaml`. Aucune action requise
  en temps normal. Si vous touchez aux slugs DB (rare), reproduire les 5
  propagations de la migration `20260401152848` — voir
  [habilitation_type_dynamique.md](./habilitation_type_dynamique.md#points-dattention).
- **`add_attribute` oublié** — un attribut défini par `attr_accessor`
  n'est pas dans `extra_attributes`, n'est pas persisté dans `data`,
  n'est pas exposé au form. Silencieux à l'exécution, visible au test.

## Checklist

À copier dans la description de PR :

```
- [ ] Concern créé dans `app/models/concerns/authorization_extensions/<name>.rb`
- [ ] Validations gardées par `need_complete_validation?(:<name>)`
- [ ] Entrée ajoutée dans `BLOCK_MODULES` (ou `BLOCK_PROCS`)
- [ ] Présence dans `BLOCK_ORDER` décidée (ou gating volontaire documenté)
- [ ] Vue form `_<name>.html.erb` (default) créée
- [ ] Vue step wizard `build/<name>.html.erb` créée
- [ ] Vue summary `_<name>.html.erb` (default) créée
- [ ] Wordings ajoutés dans `fr.yml`, `authorization_request_forms.fr.yml`, `activerecord.fr.yml`
- [ ] Spec ajoutée dans `dynamic_authorization_request_registrar_spec.rb`
- [ ] Trait `with_<name>` ajoutée dans la factory si pertinent
- [ ] Test e2e cucumber écrit
- [ ] `make lint`, `make tests`, `make e2e` au vert
```