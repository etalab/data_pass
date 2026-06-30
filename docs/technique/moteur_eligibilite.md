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

**Résolution de la règle** : par convention, sur la **classe de la démarche**
démodulisée :

```ruby
"EntityEligibility::Rules::#{authorization_request_form.authorization_request_class.name.demodulize}".constantize
```

`HubEECertDC` → `Rules::HubEECertDC`, `APIEntreprise` → `Rules::APIEntreprise`.
Si aucune règle n’existe (`NameError`), le verdict est `unknown`.

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

La lecture des données brutes de l’organisation (catégorie juridique, code NAF…)
et les prédicats **spécifiques à une démarche** (ex. `commune?`, `menuiserie?`)
vivent dans la règle concernée, pas dans `Base` : l’intelligence métier reste au
plus près de son usage.

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
| `APIEntreprise` | menuiserie (code NAF/APE `activitePrincipaleUniteLegale` ∈ `16.23Z`, `43.32A`, `43.32B`) | `ineligible(:menuiserie)`, sinon `unknown` |

> La règle `APIEntreprise` colle volontairement à la spec (cas 2 : « entreprise de
> menuiserie → invalide ») : elle ne tranche **que** ce cas précis via le code NAF,
> et renvoie `unknown` partout ailleurs plutôt que de sur-généraliser. Les autres
> signaux (catégorie juridique, effectif…) viendront enrichir la règle au fil des
> cas réels.

## Limites connues / à venir

- **Couverture partielle d’`APIEntreprise`** : seule la menuiserie est tranchée.
  La généralisation (qui est éligible / inéligible / `likely_*`) reste à
  construire sur des cas concrets.
- **Cas 3 (SNCF « likely valide »)** non couvert : SA à capitaux publics, c’est la
  nuance qui motivera l’usage de `likely_eligible`, en croisant d’autres signaux
  (tranche d’effectif, INPI… cf. API-7000/7002).
- **Détection des entités** : signaux disponibles dans le payload INSEE
  (catégorie juridique, code NAF, effectif). Fiabilisation possible via le JDD des
  administrations (API-6998) sans changer l’API du moteur.
- **Câblage UI / instruction** : le moteur est pour l’instant un service
  read-only ; le branchement sur l’écran d’instruction (API-7004) et la
  persistance d’un score (API-7000) restent à faire.
