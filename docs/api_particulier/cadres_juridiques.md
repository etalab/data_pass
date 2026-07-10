# Cadres juridiques des formulaires API Particulier

Cette page recense les formulaires de demande d’habilitation API Particulier, leur éditeur, et le cadre juridique auquel chacun est rattaché.

Le cadre juridique (`cadre_juridique_nature`) est le texte de référence pré-rempli dans le formulaire au moment de la demande. Il est stocké en snapshot à la soumission (`data` en hstore) : une modification du cadre n’a aucun effet rétroactif sur les demandes déjà soumises.

Source de vérité : `config/authorization_request_forms/api_particulier.yml`. Cette page en est le reflet documentaire — la régénérer si les cadres ou formulaires évoluent.

## Les 6 cadres canoniques

Chaque cadre est factorisé en une ancre YAML unique, réutilisée par tous les formulaires du même cadre.

| Cadre | Ancre YAML | Formulaires | Texte du cadre juridique |
|---|---|---:|---|
| **Socle général** | `socle_general` | 46 | - Cadre légal général : L’article L114-8 du Code des relations entre le public et l’administration définit le cadre juridique général en vertu duquel les administrations sont tenues d’échanger les données requises dans le cadre des démarches engagées par les usagers. |
| **CCAS** | `ccas` | 6 | - Cadre légal général : L’article L114-8 du Code des relations entre le public et l’administration définit le cadre juridique général en vertu duquel les administrations sont tenues d’échanger les données requises dans le cadre des démarches engagées par les usagers.<br>- Cadre légal spécifique aux CCAS : Les articles L.123-5 et R.123-2 du Code de l’Action Sociale et des familles qui confient aux CCAS la charge de mener une action générale de prévention et de développement social dans la commune par le biais de prestations en espèces, remboursables ou non et de prestations en nature.<br>- Cadre légal spécifique pour les aides facultatives des CCAS : L’article R.123-21 du Code de l’Action Sociale et des familles donnant toute liberté au CCAS pour définir les conditions d’attribution des aides sociales facultatives. |
| **Cantines** | `cantines` | 6 | - Cadre légal général : L’article L114-8 du Code des relations entre le public et l’administration définit le cadre juridique général en vertu duquel les administrations sont tenues d’échanger les données requises dans le cadre des démarches engagées par les usagers.<br>- Cadre légal spécifique à la restauration scolaire : L’article R531-52 du Code de l’éducation confère aux collectivités territoriales compétentes la responsabilité de fixer les tarifs des services de restauration scolaire. |
| **Transport** | `transport_complet` | 6 | - Cadre légal général : L’article L114-8 du Code des relations entre le public et l’administration définit le cadre juridique général en vertu duquel les administrations sont tenues d’échanger les données requises dans le cadre des démarches engagées par les usagers.<br>- Cadres légaux spécifiques : Les articles L1231-1 et L1231-3 du Code des transports pour les transports en commun ; les articles L. 3111-7 du Code des transports et L. 214-18 du Code de l’éducation pour les transports scolaires ; l’article L1113-1 du Code des transports en cas d’utilisation de la complémentaire santé solidaire comme critère de tarification. |
| **Stationnement résidentiel** | `stationnement_residentiel` | 3 | - Cadre légal général : L’article L114-8 du Code des relations entre le public et l’administration définit le cadre juridique général en vertu duquel les administrations sont tenues d’échanger les données requises dans le cadre des démarches engagées par les usagers.<br>- Cadre légal spécifique au stationnement résidentiel : Les articles L2333-87 et L2333-87-3 du Code général des collectivités territoriales. |
| **Aides facultatives** | `aides_facultatives` | 4 | - Cadre légal général : L’article L114-8 du Code des relations entre le public et l’administration définit le cadre juridique général en vertu duquel les administrations sont tenues d’échanger les données requises dans le cadre des démarches engagées par les usagers.<br>- Ces aides sont attribuées sur délibération de la collectivité. |

## Formulaires par cadre

### Socle général — 44 formulaire(s)

| Éditeur | Nom du formulaire | Formulaire (slug) |
|---|---|---|
| `3d_ouest` | Logiciel Enfance | `api-particulier-3d-ouest` |
| `acheteza` | AchetezA | `api-particulier-acheteza` |
| `agedi` | Proxima.ENF | `api-particulier-agedi-proxima-enf` |
| `agora_plus` | Agora Plus | `api-particulier-agora-plus` |
| `aiga` | iNoé | `api-particulier-aiga` |
| `aiga` | iNoé \| Malice Petite enfance | `api-particulier-aiga-petite-enfance` |
| `amiciel` | Malice | `api-particulier-amiciel-malice` |
| `andyvie` | Recreo | `api-particulier-andyvie` |
| `arpege` | Concerto | `api-particulier-arpege-concerto` |
| `arpege` | Concerto Petite enfance | `api-particulier-arpege-concerto-petite-enfance` |
| `ars-data` | DuoNET | `api-particulier-ars-data` |
| `berger_levrault` | BL Enfance | `api-particulier-bl-enfance-berger-levrault` |
| `carte_plus` | Carte Plus | `api-particulier-carte-plus` |
| `carte_plus` | Carte+ Petite enfance | `api-particulier-carte-plus-petite-enfance` |
| `ciril_group` | Civil Enfance | `api-particulier-civil-enfance-ciril-group` |
| `cosoluce` | Fluo | `api-particulier-cosoluce-fluo` |
| `dialog` | Memberz | `api-particulier-dialog` |
| `docaposte` | FAST | `api-particulier-docaposte-fast` |
| `e1os` | Epéris | `api-particulier-e1os` |
| `ecorestauration` | Loyfeey | `api-particulier-ecorestauration-loyfeey` |
| `familea` | Domino web 2.0 | `api-particulier-familea` |
| `familea` | Domino web 2.0 | `api-particulier-abelium` |
| `familea` | Domino Web 2.0 Petite enfance | `api-particulier-familea-petite-enfance` |
| `familea` | Domino Web 2.0 Petite enfance | `api-particulier-abelium-petite-enfance` |
| `ganesh_education` | Ganesh Education | `api-particulier-ganesh-education` |
| `jcdeveloppement` | FamilyClic | `api-particulier-jcdeveloppement-familyclic` |
| `jdealise` | Cantine de France | `api-particulier-cantine-de-france` |
| `jvs_mairistem` | Mairistem | `api-particulier-jvs-mairistem` |
| `mushroom_software` | City Family | `api-particulier-city-family-mushroom-software` |
| `mushroom_software` | City Family Petite enfance | `api-particulier-city-family-mushroom-software-petite-enfance` |
| `nfi` | NFI | `api-particulier-nfi` |
| `noethys` | Noethys | `api-particulier-noethys` |
| `odyssee_informatique` | Pandore | `api-particulier-odyssee-informatique-pandore` |
| `qiis` | eTicket | `api-particulier-qiis-eticket` |
| `resagenda` | Res'Agenda | `api-particulier-resagenda` |
| `sigec` | Maelis Petite enfance | `api-particulier-sigec-maelis-petite-enfance` |
| `sigec` | Maelis Portail | `api-particulier-sigec-maelis` |
| `teamnet` | Axel | `api-particulier-teamnet-axel` |
| `teamnet` | Axel petite enfance | `api-particulier-teamnet-axel-petite-enfance` |
| `technocarte` | Babicarte Petite enfance | `api-particulier-technocarte-babicarte` |
| `technocarte` | ILE - Kiosque famille | `api-particulier-technocarte-ile` |
| `waigeo` | MyPérischool | `api-particulier-waigeo-myperischool` |
| `ypok` | Ykidz | `api-particulier-ypok-ykidz` |
| _demande générique_ | Gestion RH du secteur public | `api-particulier-gestion-rh-secteur-public` |
| _demande générique_ | Tarification sociale des services municipaux à la petite enfance | `api-particulier-tarification-eaje` |
| _demande générique_ | Tarification sociale des services municipaux à l’enfance | `api-particulier-tarification-municipale-enfance` |

### CCAS — 6 formulaire(s)

| Éditeur | Nom du formulaire | Formulaire (slug) |
|---|---|---|
| `afi` | Mélissandre | `api-particulier-ccas-melissandre-afi` |
| `arche_mc2` | Millésime Action Sociale | `api-particulier-ccas-arche-mc2` |
| `arpege` | Sonate | `api-particulier-ccas-arpege` |
| `paxtel` | Paxtel | `api-particulier-ccas-paxtel` |
| _demande générique_ | Aides sociales des CCAS | `api-particulier-aides-sociales-ccas` |
| _demande générique_ | Aides sociales des CCAS dont aides facultatives | `api-particulier-aides-sociales-ccas-dont-facultatives` |

### Cantines — 6 formulaire(s)

| Éditeur | Nom du formulaire | Formulaire (slug) |
|---|---|---|
| `capdemat` | CapDemat Evolution | `api-particulier-capdemat-capdemat-evolution` |
| `entrouvert` | Publik Famille | `api-particulier-entrouvert-publik` |
| `kosmos` | Kosmos Education | `api-particulier-kosmos-education` |
| `mgdis` | Aiden, Tarification cantine | `api-particulier-mgdis-tarification-cantines-lycees` |
| _demande générique_ | Tarification cantine collèges | `api-particulier-tarification-cantines-colleges` |
| _demande générique_ | Tarification cantine lycées | `api-particulier-tarification-cantines-lycees` |

### Transport — 6 formulaire(s)

| Éditeur | Nom du formulaire | Formulaire (slug) |
|---|---|---|
| `airweb` | Airweb | `api-particulier-airweb` |
| `coexya` | ICAR | `api-particulier-coexya` |
| `esabora` | PourMesDossiers | `api-particulier-esabora-pourmesdossiers` |
| `keolis` | Keolis | `api-particulier-keolis` |
| `monkey_factory` | MaaSify | `api-particulier-monkey-factory-maasify` |
| _demande générique_ | Tarification des transports | `api-particulier-tarification-transports` |

### Stationnement résidentiel — 3 formulaire(s)

| Éditeur | Nom du formulaire | Formulaire (slug) |
|---|---|---|
| `extenso_partner` | Extenso Cloud | `api-particulier-extenso-partner-extenso-cloud` |
| `polycea` | eovia | `api-particulier-polycea` |
| _demande générique_ | Gestion du stationnement résidentiel | `api-particulier-stationnement-residentiel` |

### Aides facultatives — 4 formulaire(s)

| Éditeur | Nom du formulaire | Formulaire (slug) |
|---|---|---|
| `arche_mc2` | Solis | `api-particulier-arche-mc2-solis` |
| `mgdis` | Aides facultatives départementales | `api-particulier-mgdis-aides-facultatives-departementales` |
| _demande générique_ | Aides facultatives départementales | `api-particulier-aides-facultatives-departementales` |
| _demande générique_ | Aides facultatives régionales | `api-particulier-aides-facultatives-regionales` |

### Cadre non renseigné — 1 formulaire(s)

| Éditeur | Nom du formulaire | Formulaire (slug) |
|---|---|---|
| _demande générique_ | Demande libre | `api-particulier` |

> **Point d’attention** : seule la « Demande libre » (`api-particulier`) n’a pas de `cadre_juridique_nature` pré-rempli dans `initialize_with`, ce qui est attendu pour ce formulaire libre.

