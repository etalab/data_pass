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

À l’arrivée sur le bloc, `Organization#legal_category` (cf API-6829) décide :

| legal_category | mode | stockage |
|----------------|------|----------|
| `:commune` | auto | `communes_codes_insee` = [code de l’établissement] |
| `:dept` | auto | `departements_codes_insee` = [dept dérivé via geo] |
| `:region` | auto | `regions_codes_insee` = [région dérivée via geo] |
| `:other` ou INSEE incomplet | manuel | `communes_codes_insee` saisis à la main |

- **Dérivation** : `OrganizationPerimeterDeriver` lit le `codeCommuneEtablissement` local et, pour dept/région, appelle `GeoAPIGouvClient#commune`.
- **Pré-remplissage** : `PrefillGeographicPerimeter` est déclenché par un `after_commit on: :create` (sur les demandes portant le bloc) ; idempotent (ne réécrit pas une saisie existante) ; un geo en échec est avalé (la demande reste créée, périmètre vide → mode manuel).
- **Affichage** : la vue rend un conteneur (`data-cnous-perimeter-type/code`) sans déclencher d’appel serveur. Le contrôleur Stimulus `cnous-perimeter` interroge directement `geo.api.gouv.fr` selon le type :
  - `commune` → `/communes/{code}?fields=nom` (libellé seul) ;
  - `departement` → `/departements/{code}?fields=nom` (libellé) + `/departements/{code}/communes?fields=nom` (liste + compte) ;
  - `region` → `/regions/{code}?fields=nom` (libellé) + `/regions/{code}/departements` puis agrégat des communes de chaque département (geo.api n’expose pas `/regions/{code}/communes`).

  Le résumé (libellé + nombre de communes) s’affiche au `connect` ; la liste complète est révélée au clic sur « Voir toutes les communes ». En cas d’échec réseau, un message « indisponible » est affiché.

  > Tests : faute de mock HTTP navigateur (WebMock n’intercepte que le Ruby), les scénarios cucumber `@javascript` qui affichent le périmètre tapent la **vraie** geo.api. Le pré-remplissage (serveur) reste stubbé via WebMock.

DataPass **collecte** la déclaration de périmètre (les trois clés `*_codes_insee` dans `data`) et l’expose telle quelle dans l’API. La résolution canonique dept/région → liste de communes pour le consumer est faite **en aval** (relais, cf API-6835).
