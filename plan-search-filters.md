# Plan — Filtres "rôle" et "définition" sur la recherche admin/manager

## Objectif

Sur `/admin/gestion-des-droits` (et idéalement aussi
`/instruction/gestion-des-droits`), ajouter à la barre de recherche existante
deux selects pour filtrer la liste des utilisateurs :

1. **Rôle** : reporter, instructor, manager, developer, admin.
2. **Définition / FD** : une définition précise (ex. API Entreprise) ou un
   FD-wildcard (ex. « Tous les services DINUM »).

Les filtres se combinent avec la recherche texte existante (email / nom /
prénom) et avec la pagination.

---

## État actuel

- `Admin::UserRightsController#index` filtre par `User.with_any_role_on(...)`
  puis applique `ransack(params[:search_query])` avec une seule clé :
  `:email_or_given_name_or_family_name_cont`.
- Le partial `instruction/user_rights/index` rend la barre de recherche dans
  un `<turbo-frame id="user_rights_table">` avec auto-submit Stimulus
  (debounce 500ms, mode `input`).
- Pagination Kaminari : `.page(params[:page]).per(50)`.
- Ransacker `User.api_role` existant : retourne l'ensemble des
  `definition_id` d'un user (en dépliant les `provider:*:role` via les
  `AuthorizationDefinition` du provider). Déjà utilisé par
  `Admin::UsersWithRolesController`.

---

## Backend — deux ransackers complémentaires

### Filtre 1 — `role_type_cont`

Nouveau ransacker `User.role_type` : agrège les types de rôles présents
sur l'utilisateur en chaîne CSV. Le rôle `admin` est conservé tel quel ;
les rôles `provider:def:role_type` extraient le 3ᵉ segment.

```ruby
ransacker :role_type do |_parent|
  Arel.sql(role_type_ransacker_sql)
end

def self.role_type_ransacker_sql
  <<~SQL.squish
    (SELECT COALESCE(string_agg(DISTINCT role_type, ','), '')
     FROM (
       SELECT CASE elem WHEN 'admin' THEN 'admin'
              ELSE split_part(elem, ':', 3) END AS role_type
       FROM unnest(users.roles) AS elem
     ) t)
  SQL
end
```

Ajouter `role_type` à `ransackable_attributes`. Le predicate `_cont` colle
au pattern existant (`api_role_cont`) et fonctionne car les 5 valeurs
possibles ne sont pas sous-chaînes l'une de l'autre.

### Filtre 2 — `api_role_cont` (existant, à réutiliser)

Aucun nouveau code côté ransack — l'existant gère déjà :
- les rôles `provider:def:role` (`def_id` extrait directement),
- les rôles FD-wildcard `provider:*:role` (`def_id` dérivé via la table
  `(def_id, provider_slug)` matérialisée dans `api_role_fd_expansion_sql`).

Recherche `api_role_cont 'api_entreprise'` matche un user qui a soit
`dinum:api_entreprise:reporter`, soit `dinum:*:manager`.

**Limite** : `api_role_cont` ne distingue pas l'« accès indirect via FD »
de l'« accès direct ». Pour le besoin admin (filtrer sur définition pour
voir qui a un droit applicable), c'est ce qu'on veut. À documenter.

### Filtre par FD-wildcard explicite (option à trancher)

Si le métier veut pouvoir filtrer **uniquement** sur les rôles FD-wildcard
(« utilisateurs FD-managers de DINUM »), il faut un 3ᵉ filtre : un select
de `provider_slug` couplé à un ransacker `fd_provider` qui remonte les
slugs où l'utilisateur a `provider:*:role`. Pas dans la portée initiale.

---

## Frontend — `instruction/user_rights/index.html.erb`

Restructurer la barre de recherche en grille de 3 colonnes (texte + 2
selects) — pattern emprunté à `app/views/admin/users_with_roles/index.html.erb`.

```erb
<%= search_form_for @search_engine,
                    url: user_rights_index_path,
                    html: { method: :get,
                            data: { controller: 'auto-submit-form',
                                    'auto-submit-form-debounce-interval-value' => 500,
                                    'auto-submit-form-event-mode-value' => 'input' } } do |f| %>
  <div class="fr-grid-row fr-grid-row--gutters fr-mb-3w">
    <div class="fr-col-12 fr-col-md-6">
      <%# champ texte existant %>
    </div>

    <div class="fr-col-12 fr-col-md-3">
      <%= f.label :role_type_cont, t('.search.role_label'), class: 'fr-label' %>
      <%= f.select :role_type_cont,
                   options_for_select([[t('.search.all_roles'), '']] + role_options,
                                      params.dig(:search_query, :role_type_cont)),
                   {}, class: 'fr-select' %>
    </div>

    <div class="fr-col-12 fr-col-md-3">
      <%= f.label :api_role_cont, t('.search.definition_label'), class: 'fr-label' %>
      <%= f.select :api_role_cont,
                   options_for_select([[t('.search.all_definitions'), '']] + definition_options,
                                      params.dig(:search_query, :api_role_cont)),
                   {}, class: 'fr-select' %>
    </div>
  </div>
<% end %>
```

Helpers à exposer (helper partagé `Instruction::UserRightsHelper` ou
nouveau partial) :

```ruby
def role_options(authority)
  authority.allowed_role_types.map { |rt| [t("instruction.user_rights.roles.#{rt}"), rt] }
    .then { |opts| authority.sees_admin_role? ? opts + [[t('instruction.user_rights.roles.admin'), 'admin']] : opts }
end

def definition_options(authority)
  authority.managed_definitions.sort_by(&:name).map { |ad| [ad.name_with_stage, ad.id] }
end
```

Note importante : pour le manager, `role_options` n'inclut pas `developer`
(puisque non dans `allowed_role_types`). Mais le manager peut **voir** des
développeurs hors de son périmètre — devrait-on les exposer dans le
filtre ? À trancher (cf. questions ouvertes).

---

## UX — détails

- **Auto-submit** déjà câblé via Stimulus. Les selects déclenchent un
  submit immédiat (le mode `input` couvre aussi `change` sur les selects).
- **Empty state** : `instruction.user_rights.index.no_results` s'affiche
  déjà si `@users.empty? && @search_term.present?`. Étendre la condition
  à `params[:search_query].present?` ou refactorer en
  `@filters_applied?` calculé côté contrôleur.
- **Reset** : ajouter un bouton « Réinitialiser » qui pointe vers
  `user_rights_index_path` sans paramètres (utile quand 3 filtres se
  combinent et donnent vide).
- **Pagination** : Kaminari préserve déjà les query params via
  `paginate @users, params: request.query_parameters`. Vérifier que les
  liens de pagination conservent les filtres.

---

## Impacts contrôleur

`Admin::UserRightsController#index` (et `Instruction::UserRightsController#index`) :

- Le `@search_term` actuel ne capture que le texte. Remplacer par un
  helper `@filters_applied = params[:search_query]&.values&.any?(&:present?)`.
- L'`empty_state` vs `no_results` se branche sur `@filters_applied`.
- Le scope `managed_users_scope` reste inchangé.

---

## Tests

### Specs
- `User` : ransacker `role_type` (3-4 cas : un rôle simple, plusieurs
  rôles, FD-wildcard, admin).
- Pas de spec `api_role` à ajouter (déjà couvert par le ransacker
  existant) ; ajouter au plus un cas si on prend un user avec admin
  pour vérifier que `api_role` reste cohérent.

### Cucumber
Étendre `features/admin/gestion_des_droits/liste_des_droits.feature` avec :
- Filtre rôle = manager → ne voit que les managers.
- Filtre définition = API Entreprise → voit aussi les FD-managers du
  provider correspondant.
- Combinaison filtre + texte + pagination.

Pour le manager, ajouter dans
`features/instructeurs/gestion_des_droits/liste_des_droits.feature` :
- Filtre rôle = developer non disponible (option absente du select).
- Filtre définition limité aux définitions managées.

---

## Plan d'implémentation

| Étape | Fichiers | Tests |
|-------|----------|-------|
| 1. Ransacker `role_type` + `ransackable_attributes` | `app/models/user.rb` | `spec/models/user_spec.rb` |
| 2. Helper d'options select | `app/helpers/instruction/user_rights_helper.rb` | unitaire optionnel |
| 3. Refactor barre de recherche | `app/views/instruction/user_rights/index.html.erb` | — |
| 4. Bouton reset + état vide | view + contrôleurs | — |
| 5. i18n | `config/locales/instruction.fr.yml` | — |
| 6. Cucumber | `features/admin/gestion_des_droits/`, `features/instructeurs/gestion_des_droits/` | — |
| 7. Lint + spec full | — | rspec + rubocop |

**Effort estimé** : ~80 LOC code + ~50 LOC tests, 1 PR.

---

## Questions à trancher avant de coder

1. **Périmètre du filtre rôle côté manager** : exposer `developer`
   dans la liste de filtres alors qu'un manager ne peut pas en
   créer/modifier ? Argument pour : il peut **voir** des développeurs
   hors périmètre (readonly) — utile pour les rechercher. Argument
   contre : asymétrie avec le formulaire d'ajout/édition. Recommandation :
   exposer pour **filtrer**, le filtre suit les rôles **visibles**, pas
   les rôles **modifiables**.
   Oui, le manager doit pouvoir filtrer les développeur, l'admin doit pouvoir filtrer les admins, le manager ne doit pas pouvoir voir/filtrer les admins.

2. **Filtre définition vs FD** : un seul select mélangé (« API
   Entreprise », « Tous les services DINUM », …) ou 2 selects (def +
   provider) ? Recommandation : un seul select avec un optgroup
   « Définitions » et un optgroup « Fournisseurs de données » (ce dernier
   uniquement si l'authority `sees_fd_filter?`).
   Un seul select comme pour l'édition

3. **`api_role_cont` indirect via FD** : si je filtre « API Entreprise »,
   est-ce que je veux voir les utilisateurs `dinum:*:manager` (qui ont
   un accès indirect) ? Comportement actuel du ransacker = oui.
   Recommandation : garder, c'est l'intention métier sur la page
   « gestion des droits ».
   Oui

4. **Position du bouton reset** : à droite du formulaire, ou en lien
   discret sous l'empty state « no_results » ? Recommandation : les deux.
Go les 2

5. **Filtre admin** : on n'a actuellement pas d'option « filtrer les
   admins » dans le select rôle pour les managers. Comme `admin` n'est
   visible que pour `Rights::AdminAuthority`, ajouter conditionnellement
   l'option `admin` au select sous admin uniquement.
Non cf 1

6. **Pagination** : confirmer que `paginate @users, params:
   request.query_parameters` préserve bien les filtres ; sinon ajouter
   explicitement le hash de paramètres.
il faut que ça préserve

7. **Dois-je inclure ces filtres aussi côté manager (`/instruction/...`)
   dès cette PR**, ou uniquement côté admin ? Manager a peu de
   définitions en général donc filtre par définition moins urgent ;
   filtre par rôle reste utile. Recommandation : faire les deux dans
   la même PR puisque la vue est partagée — le coût est faible.
Oui, faire les deux dès la première PR puisque la vue est partagée.
