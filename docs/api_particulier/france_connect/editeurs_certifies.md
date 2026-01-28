# Éditeurs certifiés FranceConnect

Ce document liste les éditeurs de logiciels certifiés FranceConnect pour l'API Particulier.

## Liste des éditeurs certifiés

Les éditeurs suivants ont l'attribut `fc_certified: true` dans le fichier `config/service_providers.yml` :

| # | ID | Nom | Formulaires associés |
|---|---|---|---|
| 1 | `mgdis` | MGDIS | api-particulier-mgdis-tarification-cantines-lycees |
| 2 | `entrouvert` | Entr'ouvert | api-particulier-entrouvert-publik |
| 3 | `aiga` | Aiga | api-particulier-aiga<br>api-particulier-aiga-petite-enfance |
| 4 | `capdemat` | CapDemat | api-particulier-capdemat-capdemat-evolution |
| 5 | `ciril_group` | Ciril GROUP | api-particulier-civil-enfance-ciril-group |
| 6 | `waigeo` | Waigeo | api-particulier-waigeo-myperischool |
| 7 | `ypok` | Ypok | api-particulier-ypok |

**Total : 7 éditeurs certifiés FranceConnect**

## Configuration des scopes FranceConnect

Les éditeurs certifiés FranceConnect peuvent utiliser la modalité `france_connect` dans les demandes d'habilitation API Particulier, ce qui permet :

1. **Création automatique d'une habilitation FranceConnect unifiée** lors de la validation de la demande API Particulier
2. **Utilisation des scopes FranceConnect** en plus des scopes API Particulier :
   - `family_name` - Nom de naissance
   - `given_name` - Prénoms
   - `birthdate` - Date de naissance
   - `birthplace` - Ville de naissance
   - `birthcountry` - Pays de naissance
   - `gender` - Sexe
   - `openid` - Identifiant technique

## Configuration des formulaires

Pour les formulaires éditeurs certifiés FC, les scopes FranceConnect doivent être :

- **Affichés** dans la configuration `scopes_config.displayed`
- **Optionnellement désactivés** (lecture seule) via `scopes_config.disabled` si l'éditeur les gère automatiquement

### Exemple de configuration

```yaml
api-particulier-exemple-editeur:
  service_provider_id: exemple_editeur
  scopes_config:
    disabled:
      - cnaf_quotient_familial
    displayed:
      # Scopes API Particulier
      - cnaf_quotient_familial
      - cnaf_allocataires
      - cnaf_enfants
      # Scopes FranceConnect (pour éditeurs certifiés)
      - family_name
      - given_name
      - birthdate
      - birthplace
      - birthcountry
      - gender
      - openid
```

## Références

- Configuration des éditeurs : `config/service_providers.yml`
- Configuration des formulaires : `config/authorization_request_forms/api_particulier.yml`
- Définition des scopes : `config/authorization_definitions/api_particulier.yml`
- Concern FranceConnect : `app/models/concerns/authorization_extensions/france_connect_embedded_fields.rb`

## Notes importantes

1. **Certification FranceConnect** : Seuls les éditeurs avec `fc_certified: true` peuvent proposer l'option FranceConnect
2. **Modalités multiples** : Les demandes peuvent combiner `params`, `formulaire_qf` et `france_connect`
3. **Validation conditionnelle** : Les champs FranceConnect ne sont validés que si la modalité `france_connect` est sélectionnée
4. **Documents** : Le document `fc_cadre_juridique_document` est automatiquement copié vers l'habilitation FranceConnect créée
5. **Contact métier → Responsable traitement** : Le contact métier de la demande API Particulier est mappé automatiquement vers le responsable de traitement de l'habilitation FranceConnect

---

**Dernière mise à jour** : 2026-01-26