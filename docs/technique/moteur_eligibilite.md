# Moteur d’éligibilité des entités

> Bootstrap (API-7005) — document amené à évoluer au fil de l’itération.

## Rôle

Déterminer, pour un couple **(organisation, cas d’usage)**, si l’organisation
semble **éligible** à la démarche. Le but : aider à l’instruction (label
« Semble valide / invalide » côté instructeur, cf. API-7004), voire instruire
automatiquement à terme.

Le moteur ne lit que des données déjà connues de l’organisation (payload INSEE).
Il ne prend **aucune décision irréversible** : il produit un *verdict* consultatif.

## Vocabulaire

- **Démarche** : la classe d’`AuthorizationRequest` (ex. `HubEECertDC`,
  `APIEntreprise`). C’est la granularité des règles.
- **Cas d’usage / formulaire** : `AuthorizationRequestForm`. Une démarche porte
  plusieurs formulaires ; ils partagent la même règle d’éligibilité.
- **Verdict** : le résultat (`status` + `reason`).

## Architecture

Tout vit sous `app/services/entity_eligibility/`.

```
EntityEligibility::Engine          # point d’entrée, résout et exécute la règle
EntityEligibility::Verdict         # objet résultat (status + reason)
EntityEligibility::Rules::Base     # classe mère : outils partagés
EntityEligibility::Rules::<AR>     # une règle par démarche
```

### `Engine`

```ruby
EntityEligibility::Engine.new(
  organization:,
  authorization_request_form:,
  authorization_request: nil,        # optionnel : dispo pour des checks pré-soumission
).verdict

# Sucre à partir d’une demande existante :
EntityEligibility::Engine.from_request(authorization_request).verdict
```

L’engine **est le contexte** : il expose `organization`, `authorization_request_form`
et `authorization_request`, et se passe lui-même à la règle. La demande est `nil`
lors d’un check pré-création, présente en pré-soumission.

**Résolution de la règle** : par convention, du plus spécifique (le **cas
d’usage** du formulaire) au plus général (la **classe de la démarche**) :

```ruby
# 1. règle propre au cas d’usage, si le formulaire en porte un :
"EntityEligibility::Rules::#{demarche}::#{form.use_case.camelize}"
# 2. sinon (ou à défaut), règle de la démarche :
"EntityEligibility::Rules::#{demarche}"
# avec demarche = form.authorization_request_class.name.demodulize
```

`HubEECertDC` → `Rules::HubEECertDC` ; `APIEntreprise` + cas d’usage
`aides_financieres` → `Rules::APIEntreprise::AidesFinancieres`, avec repli sur
`Rules::APIEntreprise` (règle menuiserie) pour les autres cas d’usage. La
première constante qui résout gagne (`safe_constantize`) ; si aucune n’existe, le
verdict est `unknown`.

C’est ce niveau **cas d’usage** qui permet de cibler une règle sur **un seul
formulaire** d’une démarche multi-formulaires comme API Entreprise (≈ 20 cas
d’usage), sans toucher aux autres.

### `Verdict`

Statuts (`Verdict::STATUSES`), dans l’ordre du plus favorable au moins certain :

| status | sens | label instructeur |
|--------|------|-------------------|
| `eligible` | éligible | Semble valide |
| `likely_eligible` | probablement éligible | Semble valide (à confirmer) |
| `likely_ineligible` | probablement inéligible | Semble invalide (à confirmer) |
| `ineligible` | inéligible | Semble invalide |
| `unknown` | pas de règle / indéterminé | — |

Chaque statut expose un prédicat (`verdict.eligible?`, …) et porte une `reason`
symbolique pour expliciter la décision côté UI.

### `Rules::Base`

Classe mère portant uniquement les **outils génériques**, réutilisables par
toutes les règles :

- accès au contexte : `organization`, `authorization_request` ;
- builders de verdict générés depuis `Verdict::STATUSES` :
  `eligible(reason)`, `ineligible(reason)`, `likely_eligible(reason)`, etc.

Les **attributs nommés** de l’organisation (catégorie juridique, code NAF…) vivent
sur `Organization` (`legal_category`, `categorie_juridique`, `activite_principale`,
`code_commune_etablissement`, `entity_type`…) : une règle ne replonge jamais dans
`insee_payload`. `entity_type` (`:administration | :gray_zone | :other`) dérive la
typologie d’entité du **niveau 1 de la catégorie juridique** (`7…` administratif →
`:administration`, `4…` public à caractère commercial type EPIC → `:gray_zone`, sinon
`:other`) — c’est le signal qui motive un verdict `likely_eligible` pour la zone grise.
Seuls les prédicats **spécifiques à une démarche** (ex. `commune?`, `menuiserie?`)
vivent dans la règle concernée, pas dans `Base` : l’intelligence métier reste au
plus près de son usage, mais elle s’appuie sur ces accesseurs partagés.

## Ajouter une règle

1. Créer `app/services/entity_eligibility/rules/<ar_class>.rb` héritant de `Base`,
   nommée comme la classe d’`AuthorizationRequest` (les acronymes — `API`,
   `HubEE`, `DC`… — suivent les inflections du repo).
2. Implémenter `#verdict`, en s’appuyant sur les outils de `Base` et sur des
   prédicats privés propres à la règle.
3. Couvrir avec un spec sous `spec/services/entity_eligibility/rules/`.

```ruby
class EntityEligibility::Rules::HubEECertDC < EntityEligibility::Rules::Base
  def verdict
    return eligible(:commune) if commune?

    ineligible(:not_a_commune)
  end

  private

  def commune?
    organization.legal_category == :commune
  end
end
```

## Cas câblés

| Démarche | Règle | Verdict |
|----------|-------|---------|
| `HubEECertDC` | commune (`legal_category == :commune`) | `eligible(:commune)`, sinon `ineligible(:not_a_commune)` |
| `APIEntreprise` | menuiserie (code NAF/APE `organization.activite_principale` ∈ `16.23Z`, `43.32A`, `43.32B`) | `ineligible(:menuiserie)`, sinon `unknown` |
| `AideFinanciere` | typologie d’entité (`organization.entity_type`) | `:administration` → `eligible(:administration)` ; `:gray_zone` → `likely_eligible(:public_commercial)` ; sinon `ineligible(:not_administration)` |
| `APIEntreprise` + cas d’usage `aides_financieres` | typologie d’entité (`organization.entity_type`) | idem `AideFinanciere` — règle ciblée sur ce seul cas d’usage d’API Entreprise |

> La règle `APIEntreprise` colle volontairement à la spec (cas 2 : « entreprise de
> menuiserie → invalide ») : elle ne tranche **que** ce cas précis via le code NAF,
> et renvoie `unknown` partout ailleurs plutôt que de sur-généraliser. Les autres
> signaux (catégorie juridique, effectif…) viendront enrichir la règle au fil des
> cas réels.

## Limites connues / à venir

- **Couverture partielle d’`APIEntreprise`** : seule la menuiserie est tranchée.
  La généralisation (qui est éligible / inéligible / `likely_*`) reste à
  construire sur des cas concrets.
- **`likely_eligible` (zone grise)** est exercé par `AideFinanciere` via
  `entity_type == :gray_zone` (EPIC, public à caractère commercial). L’affinage du
  signal (SA à capitaux publics, tranche d’effectif, INPI… cf. API-7000/7002) reste
  à venir.
- **Détection des entités** : signaux disponibles dans le payload INSEE
  (catégorie juridique, code NAF, effectif). Fiabilisation possible via le JDD des
  administrations (API-6998) sans changer l’API du moteur.
- **Persistance d’un score** (API-7000) : le verdict est recalculé à la volée, non
  stocké.

## Câblage de bout en bout

La démarche `AuthorizationRequest::AideFinanciere` (navigable via
`/demandes/aide_financiere/nouveau`) donne au moteur une démarche réelle à résoudre :
l’`Engine` la mappe sur `Rules::AideFinanciere` par convention de nom.

Sur l’écran d’instruction d’une demande
(`instruction/authorization_requests#show`), le contrôleur calcule
`EntityEligibility::Engine.from_request(@authorization_request).verdict` et la vue
affiche le verdict via `Molecules::Instruction::EntityEligibilityVerdictComponent`
— un badge DSFR « Semble valide / invalide » (API-7004), aide à la décision pour
l’instructeur.

Le jeu de seeds crée trois demandes `Aide financière` couvrant les trois verdicts
(commune → `eligible`, EPIC → `likely_eligible`, société privée → `ineligible`)
pour observer le badge sans chercher de SIRET réel.

### Côté demandeur — introduction de formulaire (API-7001)

À l’ouverture d’un formulaire (`authorization_request_forms#new`), le contrôleur
calcule le verdict **en pré-création** (sans demande) :

```ruby
EntityEligibility::Engine.new(
  organization: current_organization,
  authorization_request_form: @authorization_request_form,
).verdict
```

`Molecules::AuthorizationRequestForms::EntityEligibilityIntroComponent` rend le
bloc, au-dessus des étapes du formulaire :

- `unknown` → `render?` faux : intro inchangée (aucune règle ne tranche) ;
- `eligible` / `likely_*` → encadré léger coloré (icône + texte), non bloquant ;
- `ineligible` → prise en charge forte : explication, **masquage des étapes**, et
  CTA « Débuter ma demande » **grisé/désactivé**. Le repli de contact
  (`mailto:` vers le `support_email` du fournisseur) reste porté par le bloc
  d’éligibilité. Le blocage est porté par l’UI : le moteur reste consultatif, mais
  le parcours de dépôt est volontairement coupé pour une entité jugée inéligible.

### i18n — convention par règle avec repli `base`

Les libellés demandeur vivent sous `entity_eligibility` (`config/locales/
entity_eligibility.fr.yml`), keyés **par règle** (démarche) avec un `base`
générique qu’on remonte :

```
entity_eligibility:
  base:            { <status>.{title,body_html}, reasons.<reason>, contact.* }
  api_entreprise:  { reasons.menuiserie: "D’après son activité déclarée (menuiserie)" }
```

Le composant résout `entity_eligibility.<rule_key>.<path>` avec repli sur
`entity_eligibility.base.<path>` (`default:`). Par convention tout vient de `base` ;
on n’écrit dans la branche d’une règle que l’override propre à la démarche. Le
`rule_key` est dérivé comme la résolution de règle de l’`Engine`
(`authorization_request_class.name.demodulize.underscore`).

> Le badge d’instruction garde pour l’instant ses propres libellés (formulation
> orientée instructeur, distincte de l’usager) ; il pourra être rebranché sur cette
> convention `base` + override ultérieurement.

## Auto-instruction

L’auto-instruction est **pilotée par convention, sans flag** : elle s’active dès
qu’une règle d’éligibilité **résout** pour le formulaire (cf. « Résolution de la
règle »). Pas de règle → verdict `unknown` → aucune action, la demande suit son
instruction humaine habituelle. C’est *convention over configuration* : écrire la
classe de règle **est** l’opt-in ; il n’y a plus de `auto_instruction: true` à
poser en configuration.

À la soumission, `SubmitAuthorizationRequest` appelle
`AutoInstructAuthorizationRequest` une fois la demande persistée :

```
verdict eligible    → ApproveAuthorizationRequest (acteur : utilisateur système)
verdict ineligible  → RefuseAuthorizationRequest  (acteur système, motif automatique)
verdict likely_* / unknown → aucune action → revue humaine
```

Seuls les verdicts **certains** déclenchent une action ; la zone grise et
l’indéterminé restent en revue humaine — c’est le garde-fou qui dispense, pour
cette première version, d’un score de confiance (API-7000). L’acteur est un
`User` « système » (les événements `approve`/`refuse` exigent un acteur ; on n’en
crée pas de bot nommé `system_`). Comme toute démarche portant une règle est
désormais auto-instruite, `HubEECertDC` (règle commune) instruit lui aussi
automatiquement à la soumission — c’est le comportement voulu (cas 1 de la spec :
commune → valide). Les seeds `Aide financière` illustrent les trois issues :
commune **validée**, EPIC en **revue**, société privée **refusée**
automatiquement.
