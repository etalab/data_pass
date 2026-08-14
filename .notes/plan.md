# Plan — DP-1734 « Fusionner les vues Utilisateurs avec rôles et Gestion des droits »

_Statut : **READY** — 5 questions tranchées (JB 2026-08-13), voir `## Décisions` en fin. Rédigé 2026-08-13._
_Linear : [DP-1734](https://linear.app/pole-api/issue/DP-1734) — MUST 100, projet Espace FD, In Progress._
_Maquette : Figma node `4044-2174` (frame `admin-utilisateurs-liste`), capture `scratchpad/dp1734-maquette.png`._

## Objectif

Fusionner les deux vues admin — **« Utilisateurs avec rôles »** (`/admin/utilisateurs-avec-roles`,
édition brute d'un textarea `roles[]`) et **« Gestion des droits »** (`/admin|instruction/gestion-des-droits`,
form structuré `Instruction::UserRightForm`) — en **une liste unique** paginée « Utilisateurs et rôles »,
accessible **admin ET manager**, avec colonnes Identité · Organisation · Rôles · Droits · Actions,
filtres par rôle + par API, badges d'état vide.

## Modèle de données (verrouillé via maquette)

Un droit stocké = string `provider_slug:definition_id:role_type` dans `users.roles[]` (array PG, inchangé).
Les deux colonnes sont **deux projections du même tableau** :

```
roles[] = ["dinum:api_entreprise:manager", "dinum:api_geo:manager", "admin"]
             │            │          │
             │            │          └─ role_type ─┐
             │            └─ definition_id ─┐       │
             └─ provider_slug              │       │
                                           ▼       ▼
   Colonne « Droits »  = definitions   Colonne « Rôles » = role_types
   (API Entreprise, API Geo)           (MANAGER, ADMIN)  ← dédupliqués, badges
   liste / « N API activées » si >2    ColorBadgeComponent.for_role
```

- **Rôles** = `role_types` **littéraux** dédupliqués (pas d'expansion hiérarchie ⇒ un manager
  s'affiche `MANAGER`, pas `MANAGER/INSTRUCTEUR/REPORTER`). Cf. Q2.
- **Droits** = `definitions` (formulaires/API) sur lesquelles l'utilisateur a un droit **spécifique**
  (`definition_id` ≠ `*`). Le traitement des droits **FD-level** (`provider:*`) est la question RG10 (Q1).

### INVARIANT — séparation autorité / affichage (décision JB 2026-08-13)

`admin` est traité comme le **super-wildcard `*:*:*`** (tous providers, tous formulaires, tous
role_types) — cf. Q4. **Ce wildcard vit uniquement dans la couche autorité/permissions**
(`Rights::*Authority`, `managed_fd_slugs`, `manages_role?`, `covers_role?`) : il détermine ce qu'un
utilisateur **peut accorder**. Il ne doit **jamais** entrer dans les projections d'affichage :

```
  ┌──────────────────────────┐        ┌───────────────────────────────┐
  │ COUCHE AUTORITÉ          │        │ COUCHE AFFICHAGE (colonnes)   │
  │ admin ⇒ *:*:*           │  ✗───▶ │ Rôles = role_types LITTÉRAUX  │
  │ (peut tout accorder)    │  jamais│ Droits = definitions EXPLICITES│
  └──────────────────────────┘        └───────────────────────────────┘
```

Conséquences : un admin s'affiche `ADMIN` (badge littéral, pas l'explosion des rôles) ; sa colonne
Droits ne liste **que** ses droits explicitement scopés à un formulaire (pas « toutes les API »).
→ tranche **Q1 vers (iii)** : tout droit implicite/wildcard (`provider:*`, `*:*:*`, `admin` atomique)
est ignoré des projections Rôles/Droits et du filtre par API.

## Existant réutilisable (carto vérifiée sur HEAD `f5d74f9a`)

| Brique | Fichier | Usage |
|--------|---------|-------|
| `Atoms::ColorBadgeComponent` + `.for_role` | `app/components/atoms/color_badge_component.rb` | badges colonne Rôles (mapping rôle→couleur déjà fait) |
| i18n rôles | `config/locales/instruction.fr.yml:658-662` | libellés badges |
| `ParsedRole` (`fd_level?`, `role`, `admin?`) | `app/models/parsed_role.rb` | parsing projections |
| `RoleSet` (`authorization_definitions`) | `app/models/role_set.rb` | definitions par kind |
| scopes User `with_roles` / `with_any_role_on` / `with_role_matching` | `app/models/user.rb:59-78` | base filtres |
| ransacker `api_role` (expansion `fd:*:role`→def ids) | `app/models/user.rb:149-183` | filtre API existant (à revoir vs RG10) |
| `Instruction::UserRightsSearch` (ransack email/nom, order email) | `app/models/instruction/user_rights_search.rb` | recherche texte, à étendre |
| `Instruction::UserRightsView` (`grouped_visible`, modifiable/readonly) | `app/models/instruction/user_rights_view.rb` | scoping visibilité par autorité |
| `TableComponent` / `TableRowComponent` | `app/components/**/instruction/user_rights/` | base table à enrichir |
| form structuré + `UserRightsPathsHelper` | `app/forms/instruction/user_right_form.rb` | action « Gérer les droits » (inchangée) |
| pagination Kaminari `.per(50)` | 3 contrôleurs | passer à `.per(10)` |

## Architecture cible (reco — cf. Q3)

Ne PAS créer de nouveau namespace. **Enrichir l'index partagé `user_rights#index`** servi dans les
deux namespaces existants — l'autorité y règle déjà l'audience :

```
              /admin/gestion-des-droits#index        /instruction/gestion-des-droits#index
   audience :  admin? (RG12)                          manager? (RG12)
   autorité :  Rights::AdminAuthority                 Rights::ManagerAuthority
   scope users: tous                                  managed_users_scope
                    └──────────────┬───────────────────────┘
                                   ▼
                   VUE FUSIONNÉE PARTAGÉE (index enrichi)
                   colonnes + filtres + pagination 10 + badges vides
                                   │
              action « Gérer les droits / modifier » ─▶ user_rights#edit (form structuré, inchangé)

   SUPPRIMÉ : app/controllers/admin/users_with_roles_controller.rb + vues + route
              (le textarea brut est remplacé par le form structuré)
```

RG12 (admin **et** manager) est satisfait par l'union des deux namespaces existants (un admin passe
par `/admin/...`, un manager par `/instruction/...`) — pas de résolution d'autorité nouvelle.
Alternative (Q3) : URL unique. Reco = garder le dual namespace (moindre churn, comportement existant).

## Flux de filtrage (RG6-RG10)

**INVARIANT DE PÉRIMÈTRE (décision JB 2026-08-13)** : la population de la liste = **`with_roles`**
(utilisateurs avec ≥ 1 rôle), **scopée par l'autorité** (admin → tous les with-roles ; manager →
`managed_users_scope`). **Jamais toute la base des demandeurs.** C'est le périmètre actuel des 3 vues —
on ne l'élargit pas. Conséquence directe : l'axe **« sans rôle » est PARQUÉ** (dans cette population,
tout le monde a un rôle → le filtre serait vide ou exigerait un modèle « rôle ≠ droit » qui contredit
RG10 ; à retravailler avec Eva, cf. section dédiée). Voir **« À valider avec Eva »**.

Un seul axe complet en v1 (Droits) + un demi-axe Rôles (choix du role_type, sans la tête avec/sans) :

```
params ──▶ UserRightsSearch (étendu) ──▶ scope User composé ──▶ .order(:email).page(p).per(10)
           (base = with_roles scopée autorité)

  axe Rôles  :  role_type ∈ {manager,instructor,developer,reporter,admin}   (littéral, RG6/CA-6)
                ⚠️ tête [Avec rôles]/[Sans rôles] (RG7) = PARQUÉE (cf. Eva)
  axe Droits :  [Avec droits] XOR [Sans droits] ⊕ definition ∈ {API…}       (spécifiques only, RG8/RG10)

  cumul (RG9) :  (sans droit) ET (role_type=manager) = without_specific_definition_rights ∩ with_role_type('manager')
  ⚠️ CA-5 (« sans rôle » ∩ API Entreprise) = PARQUÉ avec la tête « sans rôle »
```

Cas limites (shadow paths) :
- utilisateur `roles = {}` → **hors périmètre** (exclu par `with_roles`) — pas de badge « aucun rôle » en v1
- utilisateur uniquement `admin` (atomique) → Rôle `ADMIN`, Droits = **aucun** (badge « aucun droit », Q1=iii)
- utilisateur uniquement `dinum:*:manager` (FD-level) → Rôle `MANAGER`, Droits = **aucun** (badge « aucun droit », Q1=iii)
- filtre API sélectionné mais aucun match → liste vide + pagination cohérente

## Étapes (ordre CLAUDE.md : modèles → services → contrôleurs/vues → cucumber)

### Étape 1 — Modèle : projections + scopes de filtrage (+ specs)
- `User#distinct_role_types` → `roles.filter_map { ParsedRole.parse(_1).role }.uniq` (littéral,
  wildcards & `admin` NON expansés — cf. INVARIANT).
- `User#specific_authorization_definitions` → definitions des roles où `definition_id` présent et ≠ `*`
  (tous kinds), preload pour éviter N+1. Ignore `provider:*`, `*:*:*`, `admin` (Q1 = iii).
- Scopes : `with_role_type(type)`, `with_specific_definition(def_id)`,
  `with/without_specific_definition_rights`. Réutiliser `with_roles`/`with_any_role_on`.
  _(Pas de `without_roles` : « sans rôle » parqué → aucun code mort introduit.)_
- Specs modèle pour chaque méthode + scope (objets réels/seeds, pas d'assoc/validation directe).
- **Vert + rubocop avant étape 2.**

### Étape 2 — Service/Query : recherche multi-filtres cumulables (+ specs)
- **Base = `with_roles` scopée autorité** (INVARIANT de périmètre) — la recherche compose PAR-DESSUS.
- Étendre `Instruction::UserRightsSearch` (ou nouveau `Instruction::UserRightsFilter`) pour accepter :
  `text` (existant), `role_type`, `droit_presence` (with/without), `definition`/`api`. Composer en
  intersection (RG9), gérer l'exclusivité with/without côté Droits (RG8).
  - ⚠️ **PARQUÉ** : `role_presence` (tête avec/sans rôle, RG7) — non implémenté en v1 (cf. Eva). Aucun scope
    `without_roles` n'est introduit tant que ce n'est pas dé-parqué (pas de code mort).
- Options des selects : liste des role_types (i18n) + liste des definitions filtrables (RG10 : spécifiques).
- Specs : chaque filtre isolé, CA-4 (sans droits), CA-6 (rôle instructeur n'attrape pas un developer),
  exclusivité with/without Droits, cumul (sans droit ∩ role_type). **CA-5 = PARQUÉ** (dépend de « sans rôle »).
- **Vert + rubocop avant étape 3.**

### Étape 3 — Contrôleur + vues : index fusionné
- **Population = `with_roles` scopée autorité** (INVARIANT) : `managed_users_scope` reste la base (admin →
  tous with-roles ; manager → managés). Ne PAS élargir à toute la base.
- Enrichir `admin/user_rights#index` + `instruction/user_rights#index` : passer les params filtre au
  service, `.per(10)` (RG5), exposer options de filtres à la vue.
- Vue index : en-tête « Gestion des Utilisateurs » / « Administrez les accès et rôles. », barre de
  filtres (Droits [avec/sans + API], Rôles [role_type — **sans** tête avec/sans, parquée], Réinitialiser)
  + recherche existante, bouton « Ajouter un utilisateur » (→ `user_rights#new`, cf. Q5), pagination.
- Nav : remplacer les 2 entrées admin (`admin/index.html.erb:19-20`) par une seule
  « Utilisateurs et rôles » ; aligner l'entrée `InstructorMenuComponent`.
- Autorisation en contrôleur (RG12) : inchangée (admin? / manager? via policies existantes).
- Request specs si logique non couvrable en cucumber.
- **Vert + rubocop avant étape 4.**

### Étape 4 — Composants : ligne enrichie + cellule Droits + badges vides (+ previews)
- Enrichir/dupliquer `TableRowComponent` : colonnes Identité, Organisation (lien), Rôles (badges
  `ColorBadgeComponent` ; badge « aucun rôle » RG4 = **PARQUÉ** — hors périmètre `with_roles`, ne peut
  pas survenir en v1), Droits (cellule agrégée), Actions (bouton unique « Gérer les droits / modifier » — RG11).
- Cellule Droits : ≤2 → liste ; >2 → « N API activées » dépliable (RG2) via `<details>`/Stimulus ;
  vide → badge « aucun droit assigné » (RG3).
- **Infobulle « lien rôle → API » — ⚠️ COMMIT À PART** (décision JB 2026-08-13 : isolée dans son propre
  commit pour un retrait trivial si Eva n'en veut pas). Préserve le pairing perdu par le découpage 2 colonnes
  (cf. /challenge 2026-08-13). Divulgation via le composant **DSFR Infobulle** (`.fr-tooltip` + `.fr-btn--tooltip`, CSS
  déjà présent, JS core `@gouvfr/dsfr`) : **un seul déclencheur focusable (icône ⓘ) par ligne** (pas par
  droit ni par badge → évite N focusables + bruit lecteur d'écran), bulle listant les paires
  `RÔLE → API` (source : `Instruction::UserRightsView#grouped_visible`, donnée déjà groupée).
  - **Accessibilité (obligatoire)** : déclencheur = bouton/lien focusable, `role="tooltip"` +
    `aria-describedby`, id unique ; DSFR JS gère survol **+ focus clavier** + Échap + persistance
    (WCAG 1.4.13). ⚠️ jamais d'infobulle au survol d'un texte non focusable. Passer `/accessibility:audit`
    sur le composant.
  - **Afficher l'infobulle uniquement si elle sert** (décision JB 2026-08-13) : **ssi ≥ 2 role_types
    distincts ET ≥ 2 droits distincts** — comptés **sur les seuls droits spécifiques** (ignorer `admin`
    et FD-level `*`), pour ne déclencher que sur une ambiguïté many-to-many réelle. Mono-rôle, mono-API,
    admin-only, FD-level-only, badges vides → **pas** d'infobulle. Prédicat modèle
    `ambiguous_specific_pairing?` (+ projection pairée `specific_rights_by_definition`) à ajouter ici.
  - ⚠️ Limite DSFR : l'infobulle vise du **texte court**. Si un profil très riche rend la liste longue,
    replier vers un petit disclosure/popin — hors v1.
- **Revue Eva (post-hoc, non bloquant — elle est en congés)** : on livre l'infobulle conditionnée en v1 ;
  à son retour, valider infobulle ⓘ vs tags `API·RÔLE` inline vs rien. Retrait trivial si besoin (composant
  isolé + prédicat `ambiguous_specific_pairing?`). Le pairing complet reste de toute façon dans la fiche d'édition.
- **Finding /verify Étape 3 (2026-08-14)** : dans le select Droits ET la colonne Droits, les variantes
  **prod + sandbox** d'une même API partagent le **même `name`** → doublons visuels (« API CPR PRO-ADELIE »,
  « API Courtier fonctionnel SFiP »…). À traiter ici : dédupliquer/ regrouper par nom (ou distinguer
  prod/sandbox, ou masquer les sandbox du filtre). Concerne `user_rights_droit_filter_options` (Étape 3) +
  le rendu de la cellule Droits.
- Previews dans `spec/components/previews` avec objets seeds réels (dont un profil multi-rôle × multi-API
  pour exercer l'infobulle, et un mono-rôle pour prouver son absence).
- **Vert + rubocop + preview visuelle avant étape 5.**

### Étape 5 — Cucumber : CA-1 → CA-7
- Feature `features/...` couvrant les CA **v1** : CA-1 (liste/colonnes/pagination), CA-2 (badge sans droit),
  CA-4 (filtre sans droits), CA-6 (filtre rôle littéral, developer exclu), CA-7 (accès admin/manager only).
  **CA-3 et CA-5 = PARQUÉS** (dépendent de « sans rôle », cf. Eva).
- **Vert avant étape 6.**

### Étape 6 — Bug Valentin (réintégré au ticket) — **admin ⇒ `*:*:*`** (décision JB)
- Faire reconnaître le super-wildcard `*:*:*` pour `admin` dans la couche autorité : `admin?` implique
  `*:*:manager` (donc `fd_manager_for?`/`managed_fd_slugs`/`manages_role?` vrais partout) et au-delà,
  tout role_type. Reste à trancher **l'implémentation** (Q4) : (a) dériver de `admin?` (short-circuit,
  aucun stockage) vs (b) valeur `*:*:*` réellement parsée par `ParsedRole`/`RoleSet`.
- **Ne pas toucher les projections d'affichage** (INVARIANT) : `admin` reste un badge littéral, aucune
  API implicite dans Droits.
- Specs de non-régression : un admin peut donner `dinum:*:instructeur` depuis l'instruction ; un admin
  s'affiche toujours `ADMIN` seul (pas d'explosion de badges) et sans droits API implicites.
- Commentaire Linear explicatif (diagnostic + `*:*:*`) — validé par JB avant post.
- Commit séparé dans la même PR.

### Étape 7 — Nettoyage + qualité (étape finale obligatoire)
- **⚠️ Ordonnancement (décision JB 2026-08-13) : ne retirer TOUTE la mécanique « Utilisateurs avec rôles »
  qu'APRÈS que la vue fusionnée fonctionne correctement (Étapes 3-5 vertes + validée).** La page
  `users_with_roles` reste en place pendant tout le développement (filet de sécurité / comparaison),
  suppression = geste final.
- Supprimer `admin/users_with_roles` (contrôleur, vues, route `config/routes.rb:168`), et le ransacker
  `api_role` s'il devient orphelin (sinon le réutiliser étape 2).
- Reconvergence menus, vérif liens morts.
- Passe qualité : N+1 sur projections definitions (preload/counter), cohérence docs si besoin, refactor.

## Diagramme de dépendances (ce que ça touche)

```
users.roles[] (PG array, INCHANGÉ)
   ├─ ParsedRole / RoleSet / RoleHierarchy ........... projections (étape 1)
   ├─ User scopes + UserRightsSearch ................. filtres (étape 1-2)
   ├─ admin|instruction/user_rights_controller ....... index enrichi (étape 3)
   │     └─ policies (admin?/manager?) ............... RG12 inchangé
   ├─ TableRow/TableComponent + ColorBadgeComponent .. rendu (étape 4)
   ├─ nav (admin/index + InstructorMenu) ............. entrée unique (étape 3)
   ├─ users_with_roles_controller + vues ............. SUPPRIMÉ (étape 7)
   └─ Rights::ManagerAuthority / User#managed_fd_slugs  fix Valentin (étape 6)
```

## Traçabilité — quelle étape résout quel RG / CA

Légende : **impl** = étape qui implémente · **vérif** = étape qui prouve (test). Toutes les CA
sont prouvées en cucumber (Étape 5), en plus des specs unitaires de l'étape d'implémentation.

### Règles de gestion (RG)

| RG | Intitulé (résumé) | Impl | Vérif | Dépend de Q |
|----|-------------------|------|-------|-------------|
| RG1 | Ligne = identité · organisation · rôles · droits | É3 (données) + É4 (rendu) | É5 | — |
| RG2 | > 2 droits → « N API activées » dépliable | É1 (projection defs) + É4 (cellule) | É4 preview + É5 | Q1 |
| RG3 | Sans droit API → badge « aucun droit assigné » | É1 (scope) + É4 (badge) | É5 | Q1 |
| RG4 | Sans rôle → badge « aucun rôle » | ⏸️ **PARQUÉ** (hors périmètre `with_roles`) | — | Eva |
| RG5 | 10 / page paginé | É3 (`.per(10)`) | É5 | — |
| RG6 | 2 axes de filtre (rôle, API) | É2 (service) + É3 (UI) | É5 | — |
| RG7 | Filtre rôles : têtes « avec/sans » exclusives | ⏸️ **PARQUÉ** (tête avec/sans ; choix role_type conservé en É2/É3) | — | Eva |
| RG8 | Filtre droits : têtes « avec/sans » exclusives | É2 (compo) + É3 (UI) | É5 | Q1 |
| RG9 | Filtres cumulables | É2 (intersection) | É5 (sans droit ∩ role_type) | — |
| RG10 | Filtre API = droits spécifiques only (pas implicites) | É1 (`with_specific_definition`) + É2 (options) | É5 (CA-6) | **Q1** |
| RG11 | 1 seul point d'action « Gérer les droits » | É3 (route) + É4 (bouton) | É5 | Q5 |
| RG12 | Accès `administrateur` **et** `manager` | É3 (autz + nav) | É5 (CA-7) | Q3 |

### Critères d'acceptance (CA)

| CA | Intitulé (résumé) | Impl | Vérif |
|----|-------------------|------|-------|
| CA-1 | Liste colonnes IDENTITÉ/RÔLES/DROITS/ACTIONS, 10 lignes paginées | É3 + É4 | **É5** |
| CA-2 | Sans droit API → badge « aucun droit assigné » | É4 | **É5** |
| CA-3 | Sans rôle → badge « aucun rôle » | ⏸️ **PARQUÉ** (hors périmètre `with_roles`) | — |
| CA-4 | Filtre « sans droits » → seules lignes sans droit, « avec droits » désélectionné | É2 | **É5** |
| CA-5 | « sans rôle » + « API Entreprise » simultanés (cumul) | ⏸️ **PARQUÉ** (dépend de « sans rôle ») | — |
| CA-6 | Filtre rôle « INSTRUCTEUR » → un DEVELOPER n'apparaît pas | É1 + É2 | **É5** |
| CA-7 | Rôle autre qu'admin/manager → page non visible en nav | É3 | **É5** |

### Étapes hors RG/CA (périmètre élargi / dette)

| Étape | Nature | Justification |
|-------|--------|---------------|
| É6 | Fix bug Valentin (`*:*:manager` / `admin?`) | réintégré au ticket (hors RG, décision produit) |
| É7 | Suppression `users_with_roles` + reconvergence menus + passe qualité | dette générée par la fusion |

**Couverture v1** : RG1-3, RG5-6, RG8-12 + CA-1/2/4/6/7 implémentés et testés. **PARQUÉS** (à retravailler
avec Eva, cf. section dédiée) : RG4, la tête « avec/sans » de RG7, CA-3, CA-5 — tous liés à la sémantique
« sans rôle » incohérente avec le périmètre `with_roles`. Décisions produit tranchées (cf. `## Décisions`).

## Décisions (toutes tranchées — JB 2026-08-13)

1. **RG10 — droits wildcard dans colonne/filtre Droits → option (iii).** Un droit implicite/wildcard
   (`provider:*`, `*:*:*`, `admin`) n'est **jamais** compté comme droit spécifique — absent de la colonne
   Droits, du badge « N API activées » et du filtre par API. Un user uniquement wildcard → badge
   « aucun droit assigné ». Conséquence de l'INVARIANT `*:*:*`. _(Puce « toute la FD » distincte = idée
   future à valider avec Eva seulement si le besoin émerge, pas dans ce lot.)_

2. **Rôles = littéral.** Colonne et filtre affichent le `role_type` littéral, sans expansion hiérarchie
   (filtrer « instructeur » n'attrape pas les managers — cohérent CA-6). _Détail éventuel plus tard via
   une popin « détail des droits » si le besoin se fait sentir — hors lot._

3. **Archi = split conservé.** Enrichir l'index partagé `user_rights#index` dans les **2 namespaces**
   (admin + instruction), chacun avec son autorité/audience. **Pas d'URL unique.**

4. **Fix Valentin = admin ⇒ `*:*:*`, dérivé de `admin?`** (option a). Short-circuit dans la couche
   autorité (`Rights::*Authority` / `user_roles` : `managed_fd_slugs`, `manages_role?`, `covers_role?`,
   `fd_manager_for?`), **aucun** changement de stockage, **aucune** modif de `ParsedRole`/`RoleSet`.
   L'INVARIANT garantit que ça ne fuite pas dans l'affichage. Même PR, commit séparé.

5. **Bouton « Ajouter un utilisateur » = form structuré `user_rights#new`.** On abandonne le `new`
   textarea brut de `users_with_roles` (supprimé étape 7).

6. **Lien rôle → API préservé par infobulle DSFR conditionnelle** (suite `/challenge` 2026-08-13). Le
   découpage 2 colonnes perd le pairing rôle↔définition ; on le restitue via une **infobulle DSFR
   (`.fr-tooltip`), un seul déclencheur focusable ⓘ par ligne**, contenu = paires `RÔLE → API`
   (`grouped_visible`). **Affichée uniquement en cas d'ambiguïté réelle** : ≥ 2 role_types **et** ≥ 2 droits
   distincts, comptés sur les seuls **droits spécifiques** (admin/FD-level ignorés). Accessibilité = pattern
   DSFR (focusable + `role="tooltip"` + `aria-describedby`, WCAG 1.4.13). Détail en Étape 4. _Eva en congés
   → on implémente l'infobulle en v1, revue à son retour ; retirable trivialement (composant isolé +
   prédicat d'affichage) si elle préfère des tags inline ou rien._

7. **Périmètre borné + « sans rôle » parqué** (suite `/challenge` 2026-08-13). Population de la liste =
   **`with_roles` scopée autorité** (le périmètre actuel des 3 vues), **jamais toute la base des demandeurs**
   (× 100, ingérable + perf). Conséquence : le filtre/badge **« sans rôle » (RG4/RG7/CA-3/CA-5) est PARQUÉ**
   en v1 — il repose sur une contradiction de spec (dans une population `with_roles`, personne n'a « aucun
   rôle » ; le rendre utile exigerait un modèle « rôle ≠ droit » qui contredit RG10). On livre une meilleure
   vue tout de suite ; on reprend avec Eva. Le filtre/badge **« sans droit » reste, lui** (cohérent + utile).

## À valider avec Eva (à sa rentrée)

_Deux sujets soulevés par les `/challenge` du 2026-08-13. Eva est l'autrice de la maquette/du ticket ;
ces points touchent son intention produit. On a livré une v1 défendable en attendant, sans rien verrouiller
d'irréversible. Contexte à lui présenter :_

### 1. Le lien rôle ↔ API et l'infobulle

Le découpage en 2 colonnes indépendantes (**Rôles** = types de rôle · **Droits** = API) **perd le lien**
« quel rôle sur quelle API ». Ex. `manager sur API Entreprise` + `instructeur sur API Particulier` →
Rôles [MANAGER, INSTRUCTEUR], Droits [Entreprise, Particulier], sans savoir qui va avec quoi.
- **Ce qu'on a fait en v1** : une **infobulle DSFR ⓘ par ligne** (accessible, focusable) qui montre les
  paires `RÔLE → API`, **uniquement quand il y a ambiguïté** (≥ 2 rôles ET ≥ 2 droits spécifiques). Isolée
  dans son propre commit → retrait trivial.
- **À trancher avec Eva** : infobulle ⓘ (notre choix) **vs** tags `API·RÔLE` inline dans la colonne Droits
  **vs** rien (le lien reste dans la fiche d'édition). + confirmer que l'aplatissement 2 colonnes est bien
  voulu.

### 2. « Sans rôle » et le périmètre de la population

Le ticket (RG4/RG7/CA-3/CA-5) suppose qu'un utilisateur peut avoir un **droit sans rôle** — or dans le
modèle verrouillé (Rôles = role_types, Droits = definitions, **même** `roles[]`), c'est **impossible** :
un `roles[]` vide = « aucun rôle » ET « aucun droit » à la fois, et c'est justement toute la base de
demandeurs qu'on ne veut PAS lister.
- **Ce qu'on a fait en v1** : population **bornée à `with_roles`** (périmètre actuel), filtre/badge
  **« sans rôle » parqué**, **« sans droit » conservé** (utile : repère admin-only / FD-level-only).
- **À trancher avec Eva** : veut-elle vraiment un axe « sans rôle » ? Si oui, ça implique de **redéfinir
  « rôle » vs « droit »** (p. ex. rôle = instruction {manager/instructor/reporter/admin}, droit = accès
  developer/API) — ce qui **contredit RG10** tel qu'écrit. C'est une décision de modèle, pas d'affichage :
  à cadrer ensemble avant de l'implémenter.
