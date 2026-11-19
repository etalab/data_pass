# Registre wallet : registre des rulebooks

Le registre des rulebooks dit quelles attestations et quelles données une organisation peut demander
dans une utilisation prévue du registre wallet (DPP-205). En V1, il contient le PID et le permis de
conduire mobile du catalogue de la Commission européenne, et rien d’autre (décision D-18).

## Modèle

| Table | Modèle | Contenu |
| -- | -- | -- |
| `wallet_registry_rulebooks` | `WalletRegistry::Rulebook` | Un rulebook dans une version : `source`, `identifier` (`pid`, `mdl`), `version`, nom, catégorie, lien, mots-clés, `source_details` (provenance du relevé), `provisional`, `retired_at` |
| `wallet_registry_rulebook_formats` | `WalletRegistry::RulebookFormat` | L’attestation dans un format : `dc+sd-jwt` (avec `vct`) ou `mso_mdoc` (avec `doctype`) |
| `wallet_registry_rulebook_claims` | `WalletRegistry::RulebookClaim` | Une donnée, commune à tous les formats : identifiant, libellé et description en français, `requirement` (`mandatory`, `optional_by_country`, `optional_by_issuer`), groupe, ordre |
| `wallet_registry_rulebook_claim_paths` | `WalletRegistry::RulebookClaimPath` | Le chemin de la donnée dans un format (`birth_date` en mdoc, `birthdate` en SD-JWT). Une donnée absente d’un format n’a pas de chemin pour lui |

`source` vaut `eu_catalog` (catalogue de la Commission), `national` (rulebook national) ou `custom`
(rulebook défini dans DataPass). Un rulebook est unique par `source`, `identifier` et `version`.

Un rulebook ne se supprime pas : il se **retire** (`retired_at`). Le catalogue de l’étape ne propose
que les rulebooks disponibles (`WalletRegistry::Rulebook.available`) ; un brouillon qui cite un
rulebook retiré reste lisible.

## Ce qu’une utilisation enregistre

Le brouillon range des lignes qui pointent le registre : l’attestation demandée (un rulebook) et les
données demandées (des `RulebookClaim`). La structure `Credential` de la TS5 v1.6.1 (§2.4.5,
§2.4.13) n’est pas rangée : elle est **produite** à la demande par
`WalletRegistry::RulebookFormat#credential_for`, seul endroit qui la connaît, une par format.

```json
{ "format": "dc+sd-jwt", "meta": { "vct_values": ["urn:eudi:pid:1"] }, "claims": [{ "path": ["family_name"] }] }
{ "format": "mso_mdoc", "meta": { "doctype_value": "eu.europa.ec.eudi.pid.1" }, "claims": [{ "path": ["eu.europa.ec.eudi.pid.1", "family_name"] }] }
```

La copie figée de ce qui est déclaré, à l’inscription, relève du modèle de l’enregistrement (DPP-201).

## Sources et chargement

Une source produit, pour chaque rulebook, un hachage normalisé que `WalletRegistry::ImportRulebook`
charge en base. L’import est idempotent : il crée ou met à jour le rulebook, ses formats, ses
données et leurs chemins, et retire les versions précédentes du même rulebook de la même source.

Une seule source existe en V1 : le **relevé manuel** du catalogue de la Commission,
`db/wallet_registry/releve_catalogue_ue.yml`, lu par `WalletRegistry::RulebookSources::ManualReading`.
L’API du catalogue prévue par la TS11 (§5.3, `GET /schemas`) n’a pas d’adresse publique au
17/11/2026 : le contenu est repris à la main du dépôt
[`eudi-doc-attestation-rulebooks-catalog`](https://github.com/eu-digital-identity-wallet/eudi-doc-attestation-rulebooks-catalog).
Le bloc `source_details` garde le commit relu et la date du relevé.

```sh
bin/rails wallet_registry:load_manual_reading
```

Au premier déploiement, la migration `LoadWalletRegistryManualReading` charge le relevé : le
catalogue n’est jamais vide après un `db:migrate`, sur aucun environnement. La tâche, idempotente,
recharge le relevé à la demande. Les seeds l’appellent ; en test, le relevé est chargé une fois
avant la suite (rspec, Cucumber) et les tables du registre échappent aux troncatures
(`WalletRegistry::REFERENCE_TABLES`).

Les rulebooks sont **provisoires** (`provisional: true`). Le rulebook du permis de conduire renvoie à
l’ISO/IEC 18013-5 sans lister ses données : la liste vient du prototype V1 et reste à confirmer
(`provisional_note`).

### Brancher une source

Écrire une classe sous `WalletRegistry::RulebookSources` qui rend la même liste de hachages que
`ManualReading#rulebooks` (`source`, `identifier`, `version`, attributs du rulebook, `formats`,
`claims` avec leurs `paths` par format), puis appeler `WalletRegistry::ImportRulebook.call` sur
chacun. Rien d’autre ne change : le catalogue, le formulaire, l’aperçu et le récapitulatif lisent
la base.

## Ajouter une attestation au relevé manuel

1. Relire son rulebook dans le dépôt de la Commission et noter le commit.
2. Ajouter une entrée sous `rulebooks`, avec une clé courte (`pid`, `mdl`) :
   - `version` (courte, unique), `version_label`, `name` (en français), `category`,
     `documentation_url`, `schema_uri` (URI permanente du catalogue, TS11 §5.2.3, ou `~` tant
     qu’il n’en fournit pas), `keywords` (mots de la recherche du catalogue) ;
   - `formats` : pour chaque format, `vct_values` (SD-JWT VC, `dc+sd-jwt`) ou `doctype_value`
     (mdoc, `mso_mdoc`) ;
   - `groups`, puis pour chaque donnée : `id` (identifiant du rulebook), `label` et `description`
     en français, `presence` (`mandatory`, `optional_by_country` ou `optional_by_issuer`) et
     `paths`, le chemin de claim **par format**.
3. Mettre à jour le bloc `source_details` (commit, date du relevé).
4. Lancer `bundle exec rspec spec/models/wallet_registry spec/services/wallet_registry`.
5. Ajouter une migration qui appelle `WalletRegistry::RulebookSources::ManualReading.import!`,
   sur le modèle de `LoadWalletRegistryManualReading`, pour que chaque environnement charge le
   nouveau relevé à son déploiement.

### Toute correction donne une nouvelle version

Une version déjà chargée ne se corrige pas : toute modification d’un rulebook du relevé (donnée
ajoutée, retirée ou renommée, format, chemin) se déclare en changeant sa `version`. L’import crée
alors un nouveau rulebook et retire l’ancien ; les demandes déjà faites gardent l’ancienne version
et ses données.

L’import ne supprime rien. Une donnée retirée du relevé sans changer de version resterait en base,
proposée au catalogue et déclarée dans les `credentials`. Et comme l’import retire toutes les autres
versions, réimporter un relevé plus ancien remettrait en service l’ancienne version à la place de
la récente : on ne revient pas en arrière sur le relevé, on publie une nouvelle version.
