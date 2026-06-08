# Données géographiques (geo.api.gouv.fr)

## Rôle

DataPass s’appuie sur [geo.api.gouv.fr](https://geo.api.gouv.fr) pour deux usages, tous deux sur le bloc `cnous_data_extraction_criteria` (proactivité CNOUS) :

1. **Dériver le périmètre d’une collectivité** depuis son identité INSEE (mode automatique) — **côté serveur**.
2. **Afficher** les communes du périmètre à l’usager (lecture seule) — **côté navigateur**.

Le volume est faible (~10 habilitations/an) et geo.api est l’API de l’État (même niveau de fiabilité que DataPass) : pas de carte statique embarquée.

La résolution dept/région → liste de communes ne sert qu’à l’affichage. Elle est entièrement déportée dans le navigateur : le contrôleur Stimulus `cnous-perimeter` appelle directement `geo.api.gouv.fr` (CORS ouvert). DataPass n’expose **aucun** endpoint de résolution géographique ; le serveur n’appelle geo que pour la dérivation au moment du pré-remplissage.

## Client serveur — `GeoAPIGouvClient`

```ruby
GeoAPIGouvClient.new.commune('69123')
# => { code: '69123', nom: 'Lyon', code_departement: '69', code_region: '84' }  (nil si 404)
GeoAPIGouvClient.new.commune_exists?('75056')            # => Bool
```

Le client ne sert que la dérivation du périmètre (et la validation manuelle, cf API-6831) : il se limite à `commune` / `commune_exists?`. Chaque lookup est mémoïsé dans `Rails.cache` (TTL 24 h). Faraday est configuré comme les autres clients du repo (retry, `raise_error`, timeout 30 s). Une 5xx lève `GeoAPIGouvClient::ServerError`.

La liste des communes d’un département/région (pour l’affichage) n’est **pas** résolue côté serveur : voir le contrôleur Stimulus ci-dessous.

## Mode automatique vs manuel

À la création de la demande, `Organization#legal_category` (cf API-6829) décide. Le périmètre est **dérivé une fois et persisté** dans `data` sous forme de déclaration `{entity_type, code_insee_entity}` (jamais relue/recalculée à l’affichage ni à la sérialisation) :

| legal_category | mode | `entity_type` | `code_insee_entity` |
|----------------|------|---------------|---------------------|
| `:commune` | auto | `commune` | code commune de l’établissement |
| `:dept` | auto | `departement` | dept dérivé via geo |
| `:region` | auto | `region` | région dérivée via geo |
| `:other` ou INSEE incomplet | manuel | `nil` | `nil` (communes saisies dans `manual_code_insee_communes`) |

- **Dérivation + pré-remplissage** : un `after_commit on: :create` sur le bloc (méthode privée `populate_codes_insee_and_entity`) mappe `Organization#legal_category` (cf API-6829) vers un `kind` via `GEOGRAPHIC_KINDS`, lit le `codeCommuneEtablissement` local, et pour dept/région appelle `GeoAPIGouvClient#commune` pour résoudre le code dept/région. Il persiste `entity_type`/`code_insee_entity` dans `data` (via `update_columns`) ; un geo en échec (`ServerError` 5xx **ou** `Faraday::Error` timeout/connexion) est avalé (la demande reste créée, périmètre vide → mode manuel). `entity_type`/`code_insee_entity` ne sont **pas** des `add_attribute` : valeurs serveur de confiance, non modifiables au form (pas de mass-assignment).
- **Lecture** : `entity_type` / `code_insee_entity` sont lus directement dans `data` (`data['entity_type']`, `data['code_insee_entity']`) par les vues, `geographic_perimeter_automatic?` et le serializer — **aucun** appel geo en lecture.
- **Lecture** : les readers du modèle (`entity_type`, `code_insee_entity`, `geographic_perimeter_automatic?`) et le serializer ne font **aucun** appel geo — ils lisent `data`.
- **Affichage** : la vue rend un conteneur (`data-cnous-perimeter-type/code`) sans déclencher d’appel serveur. Le contrôleur Stimulus `cnous-perimeter` interroge directement `geo.api.gouv.fr` selon le type :
  - `commune` → `/communes/{code}?fields=nom` (libellé seul) ;
  - `departement` → `/departements/{code}?fields=nom` (libellé) + `/departements/{code}/communes?fields=nom` (liste + compte) ;
  - `region` → `/regions/{code}?fields=nom` (libellé) + `/regions/{code}/departements` puis agrégat des communes de chaque département (geo.api n’expose pas `/regions/{code}/communes`).

  Le résumé (libellé + nombre de communes) s’affiche au `connect` ; la liste complète est révélée au clic sur « Voir toutes les communes ». En cas d’échec réseau, un message « indisponible » est affiché.

  > Tests : faute de mock HTTP navigateur (WebMock n’intercepte que le Ruby), les scénarios cucumber `@javascript` qui affichent le périmètre tapent la **vraie** geo.api. Le pré-remplissage (serveur) reste stubbé via WebMock.

DataPass **collecte** la déclaration de périmètre (`entity_type` + `code_insee_entity` dérivés, `manual_code_insee_communes` saisis) dans `data` et l’expose telle quelle dans l’API (attribut `data` du serializer, sans traitement). La résolution canonique dept/région → liste de communes pour le consumer est faite **en aval** (relais, cf API-6835).
