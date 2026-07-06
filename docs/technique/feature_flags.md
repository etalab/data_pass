# Feature flags

Le module `FeatureFlag` (`app/models/feature_flag.rb`) centralise les **drapeaux de
déploiement progressif** : masquer une fonctionnalité tant qu'elle n'est pas prête,
ou la réserver à certains environnements ou profils d'utilisateur.

C'est la **source unique de vérité** pour ces décisions. Avant, chaque flag était
dispersé (une condition `Rails.env.production?` dans une vue, une méthode ad hoc dans
un contrôleur…). On regroupe tout ici pour que l'équipe ait une vision d'ensemble et
un seul endroit à modifier.

## Principe

Un flag est une **règle nommée** : un lambda qui renvoie `true` (fonctionnalité
visible) ou `false` (masquée). Les règles vivent dans la constante `RULES`.

```ruby
module FeatureFlag
  RULES = {
    depot_dossier_mariage: ->(**) { !Rails.env.production? },
    authorization_definitions: ->(user: nil, **) { user&.admin? || Rails.env.test? }
  }.freeze

  def self.enabled?(name, **context)
    rule = RULES[name.to_sym]

    rule.nil? || rule.call(**context)
  end
end
```

- **Nom inconnu → activé.** `enabled?` renvoie `true` si le flag n'existe pas dans
  `RULES`. Retirer une règle « allume » donc définitivement la fonctionnalité : c'est
  la manière propre de clôturer un rollout (on supprime la règle quand la
  fonctionnalité est livrée partout).
- **Contexte optionnel.** Certaines règles dépendent d'un contexte (l'utilisateur
  courant, par exemple). On le passe en mots-clés : `enabled?(:mon_flag, user:)`. Les
  règles qui n'en ont pas besoin l'ignorent grâce au `**` final.

## Utilisation

### Depuis du code Ruby

```ruby
FeatureFlag.enabled?(:depot_dossier_mariage)                  # règle par environnement
FeatureFlag.enabled?(:authorization_definitions, user: current_user)  # règle avec contexte
```

Dans un contrôleur, exposer le flag à la vue via `helper_method` peut rendr son utilisation plus lisible :

```ruby
helper_method :authorization_definitions_feature_enabled?

def authorization_definitions_feature_enabled?
  FeatureFlag.enabled?(:authorization_definitions, user: current_user)
end
```

## Ajouter un flag

1. Ajouter une règle dans `RULES` (`app/models/feature_flag.rb`), en donnant un nom
   explicite et un lambda de décision.
2. Appeler `FeatureFlag.enabled?(:mon_flag)` (avec le contexte nécessaire) partout où
   la fonctionnalité doit être conditionnée : Ruby, ERB de config, scope `feature_flag:`.
3. Couvrir la règle par un test dans `spec/models/feature_flag_spec.rb`.
4. Quand la fonctionnalité est livrée définitivement partout, **retirer la règle**
   (et les appels devenus inutiles) : un nom absent de `RULES` est toujours activé.

## Ce que ce module n'est pas

À ne pas confondre avec `AuthorizationDefinition#feature?(name)` (clé `features:` dans
le YAML d'une définition, ex. `instructor_drafts`). Ce dernier est une **capacité
configurée par formulaire**, pas un drapeau de déploiement global. Les deux concepts
sont indépendants.
