# Configuration des scopes de formulaire (`scopes_config`)

La clé `scopes_config` dans la configuration des formulaires d'autorisation permet de personnaliser l'affichage et le comportement des scopes au sein d'un formulaire spécifique.

## Structure générale

```yaml
mon-formulaire:
  name: "Mon Formulaire"
  authorization_request: "MonAPI"
  scopes_config:
    disabled: [liste des scopes désactivés]
    hide: [liste des scopes masqués]
    displayed: [liste des scopes affichés]
```

## Options disponibles

### `disabled`

**Type:** Array de strings
**Optionnel:** Oui

Liste des scopes (par valeur technique) qui seront affichés mais désactivés dans le formulaire. Les utilisateurs pourront voir ces scopes mais ne pourront pas les décocher.

```yaml
scopes_config:
  disabled:
    - scope_technique_1
    - scope_technique_2
```

**Cas d'usage :** Utile pour les formulaires d'éditeurs où certains scopes sont obligatoires et ne doivent pas être modifiables.

### `hide`

**Type:** Array de strings
**Optionnel:** Oui
**Priorité:** **HAUTE** - Prend précédence sur `displayed`

Liste des scopes (par valeur technique) qui seront complètement masqués du formulaire. Ces scopes n'apparaîtront pas dans l'interface utilisateur.

```yaml
scopes_config:
  hide:
    - scope_deprecated
    - scope_internal_only
```

**Comportement important :**
- Si un scope est présent dans `hide`, il ne sera **jamais** affiché, même s'il est également présent dans `displayed`
- Cette option prend la précédence absolue sur toutes les autres options d'affichage
- Les scopes masqués peuvent toujours être pré-remplis via `initialize_with`

### `displayed`

**Type:** Array de strings
**Optionnel:** Oui
**Priorité:** BASSE - Ignorée si `hide` est configuré pour un scope

Liste des scopes (par valeur technique) qui seront affichés dans le formulaire. Si cette clé est omise, tous les scopes de la définition sont affichés par défaut.

```yaml
scopes_config:
  displayed:
    - scope_public_1
    - scope_public_2
```

**Comportement :**
- Si `displayed` est configuré, **seuls** les scopes listés seront affichés
- Si un scope est dans `hide`, il ne sera pas affiché même s'il est dans `displayed`
- Si `displayed` n'est pas configuré, tous les scopes (sauf ceux dans `hide`) sont affichés

## Ordre de priorité

1. **`hide`** - Priorité absolue : masque complètement le scope
2. **Dépréciation** - Les scopes dépréciés pour les nouvelles entités sont automatiquement masqués
3. **`displayed`** - Contrôle quels scopes sont visibles (si `hide` ne s'applique pas)
4. **`disabled`** - Contrôle l'état interactif des scopes visibles

## Exemples d'usage

### Formulaire éditeur avec scopes obligatoires

```yaml
api-entreprise-editeur:
  name: "Formulaire Éditeur"
  authorization_request: "APIEntreprise"
  scopes_config:
    # Scopes obligatoires de l'éditeur (affichés mais non modifiables)
    disabled:
      - unites_legales_etablissements_insee
      - attestation_fiscale_dgfip
    # Scopes internes masqués
    hide:
      - scope_debug
      - scope_internal_testing
    # Seuls ces scopes sont proposés en plus des obligatoires
    displayed:
      - unites_legales_etablissements_insee
      - attestation_fiscale_dgfip
      - effectifs_urssaf
      - mandataires_sociaux_infogreffe
  initialize_with:
    scopes:
      - unites_legales_etablissements_insee
      - attestation_fiscale_dgfip
```

### Formulaire simplifié avec scopes limités

```yaml
api-particulier-simplifie:
  name: "Formulaire Simplifié"
  authorization_request: "APIParticulier"
  scopes_config:
    # Masquer les scopes avancés
    hide:
      - scope_experimental
      - scope_advanced_use
    # Afficher seulement les scopes de base
    displayed:
      - quotient_familial_caf
      - quotient_familial_msa
      - revenu_fiscal_reference
```

### Gestion des scopes dépréciés

```yaml
api-legacy:
  name: "API Legacy"
  authorization_request: "APILegacy"
  scopes_config:
    # Masquer les scopes dépréciés même pour les anciennes entités
    hide:
      - old_deprecated_scope
    # Scopes de migration affichés mais désactivés
    disabled:
      - scope_en_migration
```

## Notes importantes

- Pour modifier des demandes existantes, des migrations de données peuvent être nécessaires
- La valeur `initialize_with.scopes` peut inclure des scopes masqués par `hide` - ils seront pré-remplis mais non visibles
