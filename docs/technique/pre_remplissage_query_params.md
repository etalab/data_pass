# Pré-remplissage d'une demande via query params

Un lien direct vers le formulaire de création d'une demande accepte des query
params nommés d'après les attributs de la demande. Les valeurs sont
pré-remplies dans le formulaire et persistées en base au premier submit.

## Format d'URL

```
https://datapass.api.gouv.fr/formulaires/<form_uid>/demande/nouveau?<attribut>=<valeur>
```

Exemple :

```
https://datapass.api.gouv.fr/formulaires/api-entreprise-socle-de-base/demande/nouveau?intitule=Mon+projet&cadre_juridique_url=https%3A%2F%2Flegifrance.gouv.fr%2Ffoo
```

## Attributs pré-remplissables

L'allowlist est calculée par `AuthorizationRequest.prefillable_attribute_names`
et contient, pour la classe de demande du formulaire ciblé :

- tous les attributs déclarés via `add_attributes` (strings, dates, etc.)
- les attributs déclarés via `add_attribute(..., type: :array)` (passés en
  format Rails standard : `?modalities[]=a&modalities[]=b`)
- les checkboxes déclarées via `add_checkbox` (booleans, `?ma_case=1`)
- `scopes` si le formulaire active les scopes (`add_scopes`)

Sont volontairement **exclus** :

- les champs de contacts (`contact_technique_email`, etc.) pour éviter
  l'usurpation de l'instructeur via un lien malveillant
- les colonnes ActiveRecord (`state`, `applicant_id`, `organization_id`…)
- tout `store_accessor :data` qui ne passe pas par `add_attribute`,
  `add_checkbox` ou `add_scopes`

Tout query param qui ne matche pas l'allowlist est ignoré silencieusement.

## Mécanisme

Trois étapes :

1. **Capture** (`AuthorizationRequestFormsController#new`) : filtre les query
   params via `prefillable_attribute_names` et stocke le résultat en session,
   keyé par `form_uid` :
   ```ruby
   session[:authorization_request_prefill] = { 'form_uid' => ..., 'data' => ... }
   ```
   Si l'URL n'a aucun query param prefillable, un éventuel prefill stale de
   la même session pour ce form est nettoyé — visiter la page d'intro sans
   params réinitialise.

2. **Affichage** (`#start`) : `peek_prefill_data` lit la session sans la
   supprimer, passe les valeurs à `BuildAuthorizationRequest`. Les champs de la
   première étape (ou de la page unique) s'affichent pré-remplis via
   l'interactor `AssignQueryParamsDataToAuthorizationRequest`.

3. **Persistance** (`#create`) : `peek_prefill_data` est aussi utilisé ici,
   les valeurs sont passées à `CreateAuthorizationRequest` où l'interactor
   `AssignQueryParamsDataToAuthorizationRequest` les applique **entre les
   defaults (`initialize_with` YAML) et les params soumis** — donc le prefill
   écrase les defaults statiques, et les saisies utilisateur écrasent le
   prefill. La session n'est nettoyée qu'après que l'organizer a réussi
   (`clear_prefill_data`). Tant que le create renvoie 422, le prefill survit
   pour le submit suivant.

   Cette étape est critique pour les formulaires wicked multi-étapes : tous
   les champs pré-remplis (y compris ceux des étapes ultérieures à l'étape
   courante) sont persistés dès la soumission de la première étape. Sans
   cela, la reconstruction de la demande à chaque submit ferait perdre les
   prefill d'étapes non encore atteintes.

## Sécurité

- **XSS** : les setters générés par `add_attribute` / `add_attribute(..., type:
  :array)` appliquent `sanitize_html` (Loofah strip + `CGI.unescapeHTML`).
- **Mass assignment** : seuls les attributs de l'allowlist sont passés à
  `assign_attributes`. Les colonnes critiques (`state`, `applicant_id`…) et
  les contacts restent inaccessibles.
- **Type confusion** : si un setter raise (ex. string passée à un array
  attribute non parsable en JSON), l'interactor rescue et skip l'attribut.
- **Scoping session** : un prefill capturé pour un `form_uid` est ignoré si
  l'utilisateur consomme via un autre `form_uid`.

## Étendre l'allowlist

Ajouter un nouveau champ pré-remplissable :

- via `add_attribute(:nom)` ou `add_checkbox(:nom)` dans la classe de demande
  → automatiquement inclus
- via `add_scopes(...)` → `scopes` automatiquement inclus

Pour autoriser un autre `store_accessor` (déconseillé pour les contacts), il
faut étendre `AuthorizationRequest.prefillable_attribute_names` et refaire
une analyse de sécurité (en particulier sur les risques d'usurpation
d'identité quand le champ pilote des notifications email).
