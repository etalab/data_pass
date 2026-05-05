# Flaky Tests — Analyse & Plan de correction (Avril 2026)

## Contexte

Après les corrections du PR #1404 (26 février 2026), le taux de flakiness a baissé mais
**~30% des runs CI sur `develop` échouent encore** (6 sur 20 récents), toujours avec
1 seul scénario qui fail sur ~533.

## Failures récentes (27 mars — 2 avril)

### Catégorie A : `AuthorizationRequest.last` retourne nil (3 occurrences)

**Scénarios :**
- `soumission_multiples_etapes.feature:720` (1er avril, develop)
- `soumission_multiples_etapes.feature:381` (30 mars, develop)
- `api_ficoba.feature:40` (29 mars, dependabot ; 23 mars, develop)

**Erreur :** `No authorization request found (RuntimeError)` à
`authorization_requests_steps.rb:361`

**Cause :** Le step `j'adhère aux conditions générales d'utilisation` fait
`@authorization_request || AuthorizationRequest.last`. Dans les scénarios `@javascript`
(truncation), la soumission Turbo du formulaire est asynchrone — le step suivant query
la DB avant que Puma ait fini de traiter la requête.

### Catégorie B : Perte de session (2 occurrences)

**Scénarios :**
- `dashboard_empty_states.feature:18` (31 mars, develop)
- `modification_depuis_resume_habilitation.feature:17` (27 mars, develop)

**Erreur :** `expected to find text "..." in "Bienvenue sur DataPass..."` — la page
affiche l'accueil public au lieu du contenu authentifié.

**Cause :** Le `DatabaseCleaner.clean` (truncation) d'un scénario `@javascript`
précédent tronque la table `users` pendant que Puma traite encore une requête résiduelle.
Le login du scénario suivant échoue silencieusement.

### Catégorie C : Capybara element not found (2 occurrences)

**Scénarios :**
- `auto_france_connect_authorization.feature:39` (30 mars, develop) —
  `Unable to find link or button "Valider la demande de mise a jour"`
- `transfert_habilitation.feature:43` (2 avril, dp-1665) —
  `Unable to find field "Email du nouveau demandeur" that is not disabled`

**Cause :** Timing Turbo/Stimulus — la page n'a pas fini de rendre avant que Capybara
interagisse. Le `default_max_wait_time` de 5s est insuffisant sous charge CI.

### Catégorie D : `current_user` nil malgré le guard (1 occurrence)

**Scénario :**
- `moderer_une_habilitation.feature:10` (31 mars, dp-1633)

**Erreur :** `current_user is nil — did you forget a 'je suis un(e) ...' step?`
pour `api-scolarite-de-l-eleve@gouv.fr`

**Cause :** `User.find_by(email:)` retourne nil car le record utilisateur n'est pas
visible en DB (même cause racine que la catégorie B — race condition avec truncation).

### Catégorie E : Nil non gardé à la ligne 211 (1 occurrence)

**Scénario :**
- `consultation_demande.feature:84` (30 mars, dp-1604)

**Erreur :** `undefined method 'email' for nil` à
`authorization_requests_steps.rb:211`

**Cause :** `current_user.email` n'utilise pas le guard `current_user!`.
Ce call n'a pas été corrigé dans le PR #1404.

## Analyse approfondie des causes racines

### Constat clé : les failures Catégorie A ne sont PAS dans des scénarios @javascript

L'analyse des 29 occurrences de `AuthorizationRequest.last` dans les step definitions
révèle un fait surprenant :

- **26 sur 29** sont appelées après un `FactoryBot.create` (synchrone, même connexion)
- **3** sont appelées après une soumission de formulaire UI (steps #3, #7, #13)
- **Aucune de ces 3** n'est dans un scénario `@javascript`

Les scénarios `soumission_multiples_etapes.feature` et `api_ficoba.feature` utilisent
**rack_test** (pas de navigateur, pas de Puma, pas de thread séparé). Avec rack_test :
- Les requêtes HTTP sont synchrones et in-process
- Le DB write est synchrone (pas de race condition possible)
- Tout est dans la même connexion DB et la même transaction

Alors **pourquoi `AuthorizationRequest.last` retourne nil ?**

### Hypothèses pour la Catégorie A

1. **Fuite de la truncation d'un scénario `@javascript` précédent.** Si le scénario
   précédent dans l'ordre d'exécution était `@javascript` (truncation), et que la
   truncation n'a pas été proprement terminée avant le `Before` du scénario courant,
   les tables peuvent être dans un état incohérent. La tâche 4 (`sleep 0.2` + drain
   Puma) s'attaque à cette cause.

2. **La création de l'AR a échoué silencieusement.** L'AR est créée par le POST du
   formulaire via l'organizer `CreateAuthorizationRequest`. Si une validation échoue
   dans la chaîne d'interactors, le POST renvoie le formulaire avec des erreurs mais
   les steps suivants (cliquer sur « Suivant ») peuvent ne pas le détecter et continuer.

3. **Rollback d'une transaction imbriquée.** Avec la stratégie `:transaction`,
   `DatabaseCleaner.start` ouvre une transaction. Si le code applicatif ouvre un
   savepoint qui est rollback, les données créées à l'intérieur sont perdues.

4. **Problème d'ordre de hooks.** Les fichiers `features/support/` sont chargés par
   ordre alphabétique. Si un hook dans `env.rb` dépend d'un état défini dans un hook
   de `javascript.rb` (chargé après), l'ordre peut causer des incohérences.

### Cause racine pour les Catégories B et D

Le problème fondamental est la **course entre le thread de test et le serveur Puma**
dans les scénarios `@javascript` (stratégie truncation). Le `Capybara.reset_sessions!`
ferme la session navigateur, mais **ne garantit pas que Puma a fini de traiter les
requêtes en vol**. Le `DatabaseCleaner.clean` peut tronquer les tables pendant qu'une
requête Puma est encore en cours, ce qui corrompt l'état pour le scénario suivant.

## Inventaire des usages de `AuthorizationRequest.last`

29 occurrences au total dans 6 fichiers de step definitions :

| Contexte de création          | Nb   | Risque flaky |
|-------------------------------|------|--------------|
| Après `FactoryBot.create`     | 26   | Faible       |
| Après soumission UI (non-JS)  | 3    | Moyen        |
| En scénario `@javascript`     | 4    | Faible (FactoryBot) |

Les 3 steps à risque (soumission UI) : `je me rends sur cette demande d'habilitation`
(ligne 136), `un instructeur a validé la demande` (ligne 259), et
`j'adhère aux conditions générales` (ligne 360).

## Plan de corrections

### Tâche 1 : Résoudre `AuthorizationRequest.last` nil — Pistes étudiées

#### Piste A : `pin_connection!` — Éliminer la truncation (recommandé)

Rails 8.1 fournit `ActiveRecord::Base.connection_pool.pin_connection!(lock_threads)`
qui force le pool de connexions à retourner **la même connexion** à tous les threads.
C'est le mécanisme utilisé en interne par `ActionDispatch::SystemTestCase`.

```ruby
Before('@javascript') do
  ActiveRecord::Base.connection_pool.pin_connection!(false)
end

Before('not @javascript') do
  DatabaseCleaner.strategy = :transaction
end

Before do
  DatabaseCleaner.clean
  DatabaseCleaner.start
  Kredis.redis.flushdb
end

After do
  Capybara.reset_sessions!
  if javascript?
    ActiveRecord::Base.connection_pool.unpin_connection!
  else
    DatabaseCleaner.clean
  end
  AuthorizationDefinition.reset!
  AuthorizationRequestForm.reset!
end
```

**Avantages :**
- Tous les scénarios utilisent des transactions → cleanup par rollback, rapide
- Plus de truncation → plus de race condition entre threads
- API officielle de Rails 8.1, stable et testée
- Résout les catégories A, B et D d'un coup

**Inconvénients :**
- `pin_connection!` est `:nodoc:` (API interne, non documentée publiquement)
- Ne fonctionne pas si le code applicatif fait un `COMMIT` ou `ROLLBACK` explicite
- Nécessite d'appeler `reset_sessions!` AVANT `unpin_connection!`

#### Piste B : Capturer `@authorization_request` depuis l'URL de la page

Au lieu de requêter la DB, extraire l'ID de l'AR depuis l'URL courante après la
soumission du formulaire. Les URL suivent le pattern `/demandes/:id/...`.

```ruby
def current_authorization_request
  @authorization_request ||= begin
    match = current_path.match(%r{/demandes/(\d+)})
    AuthorizationRequest.find(match[1]) if match
  end
end
```

**Avantages :**
- Aucune dépendance à `.last` — requête explicite par ID
- Fonctionne indépendamment de la stratégie DatabaseCleaner

**Inconvénients :**
- Ne fonctionne que pour les steps qui s'exécutent sur une page dont l'URL contient
  l'ID de la demande (pas tous les cas)
- Ajoute un couplage avec le format des URLs

#### Piste C : Assigner `@authorization_request` après la création via UI

Modifier les steps de navigation post-formulaire pour capturer l'AR :

```ruby
Quand("je clique sur {string} et passe à l'étape suivante") do |label|
  click_link_or_button label
  match = current_path.match(%r{/demandes/(\d+)})
  @authorization_request = AuthorizationRequest.find(match[1]) if match && @authorization_request.nil?
end
```

Ou ajouter un `AfterStep` hook global :

```ruby
AfterStep do
  if @authorization_request.nil? && (match = current_path&.match(%r{/demandes/(\d+)}))
    @authorization_request = AuthorizationRequest.find_by(id: match[1])
  end
end
```

**Avantages :**
- `@authorization_request` est toujours défini après la première interaction avec un formulaire
- Les 29 occurrences de `.last` deviennent du dead code progressivement

**Inconvénients :**
- Le `AfterStep` s'exécute après CHAQUE step → impact performance
- Couplage avec le format des URLs
- Le `AfterStep` peut masquer des bugs si l'AR n'est pas celle attendue

#### Piste D : Remplacer `.last` par une requête scopée sur l'utilisateur courant

Au lieu de `AuthorizationRequest.last` (qui peut retourner un record d'un autre
scénario si la DB n'est pas propre), utiliser :

```ruby
def last_authorization_request
  @authorization_request || AuthorizationRequest.where(applicant: current_user).order(:created_at).last
end
```

**Avantages :**
- Plus robuste : ne peut pas retourner un record d'un autre scénario/utilisateur
- Simple à comprendre

**Inconvénients :**
- `current_user` peut être nil (même problème que catégorie D)
- Ne fonctionne pas pour les steps où l'utilisateur courant n'est pas le demandeur
  (ex: un instructeur qui consulte une demande)
- Ne résout pas le cas où l'AR n'a simplement pas été créée

#### Piste E : Préparer les records en avance via FactoryBot

Réécrire les scénarios affectés pour créer l'AR en FactoryBot dans le `Contexte`
au lieu de la créer via l'UI :

```gherkin
# Avant (création via UI — fragile)
Contexte:
  Sachant que je suis un demandeur
  Et que je me connecte
  Et que je veux remplir une demande pour "API Particulier" via le formulaire "BL Enfance"
  Et que je clique sur "Débuter ma demande"
  ...remplir les champs...

# Après (création via FactoryBot — robuste)
Contexte:
  Sachant que je suis un demandeur
  Et que j'ai une demande d'habilitation "API Particulier" en brouillon
  Et que je me connecte
  Et que je me rends sur cette demande d'habilitation
```

**Avantages :**
- Élimine complètement la dépendance à `.last` pour ces scénarios
- Plus rapide (pas de soumission de formulaire dans le setup)
- Plus fiable (FactoryBot est synchrone et dans le même thread)

**Inconvénients :**
- Change le sens du test : on ne teste plus la création via l'UI
- Les scénarios de `soumission_multiples_etapes.feature` TESTENT justement la
  soumission — les réécrire en FactoryBot annulerait leur raison d'être
- Beaucoup de scénarios à réécrire

#### Piste F : Retry/polling (plan initial)

Helper qui retry `AuthorizationRequest.last` en boucle avec un timeout.

**Avantages :** Simple, catch-all.
**Inconvénients :** Masque les bugs, ajoute de la latence, inélégant.

### Synthèse des pistes — Tâche 1

| Piste | Résout Cat. A ? | Résout Cat. B/D ? | Complexité | Élégance |
|-------|-----------------|---------------------|------------|----------|
| A. `pin_connection!`           | Oui (indirect) | **Oui**    | Moyenne | Haute |
| B. Capturer depuis l'URL       | Partiel        | Non        | Faible  | Moyenne |
| C. `AfterStep` assignation     | Oui            | Non        | Faible  | Moyenne |
| D. Requête scopée              | Partiel        | Non        | Faible  | Haute |
| E. FactoryBot pour le setup    | Oui            | Non        | Haute   | Haute |
| F. Retry/polling                | Oui            | Non        | Faible  | Basse |

**Recommandation :** Combiner les pistes **A + D** :
- **Piste A** (`pin_connection!`) élimine la cause racine des catégories B et D
  (race condition truncation) et réduit fortement la catégorie A.
- **Piste D** (requête scopée) est un filet de sécurité simple pour les `.last`
  restants, en rendant les queries déterministes par utilisateur.

### Tâche 2 : Garder `current_user!` à la ligne 211 ✅

**Fichier :** `features/step_definitions/authorization_requests_steps.rb:211`

```ruby
# Avant
"#{role}_email": current_user.email,

# Après
"#{role}_email": current_user!.email,
```

### Tâche 3 : Vérification post-login dans le step "je me connecte"

Ajouter une assertion qui détecte immédiatement si le login a échoué au lieu de
laisser le scénario continuer avec une session invalide (ce qui produit des erreurs
cryptiques plus tard).

**Fichier :** `features/step_definitions/login_steps.rb:191`

```ruby
Sachantque('je me connecte') do
  steps %(
    Quand je me rends sur la page d'accueil
    Et que je clique sur "S'identifier avec ProConnect"
  )
  raise "Login failed — still on homepage" if page.has_content?("S'identifier avec ProConnect", wait: 0)
end
```

### Tâche 4 : Drain Puma plus fiable dans le `After` hook

Le `Capybara.reset_sessions!` ne garantit pas que Puma a fini toutes les requêtes en
vol. Ajouter un court délai pour les scénarios `@javascript` afin de laisser Puma
terminer.

**Fichier :** `features/support/env.rb`

```ruby
After do
  Capybara.reset_sessions!
  sleep 0.2 if Capybara.current_driver != :rack_test
  DatabaseCleaner.clean
  AuthorizationDefinition.reset!
  AuthorizationRequestForm.reset!
end
```

Alternative plus robuste : au lieu d'un `sleep` fixe, vérifier que Puma n'a plus de
requêtes en cours via son pool de threads. À explorer si le `sleep 0.2` ne suffit pas.

### Tâche 5 : `default_max_wait_time` configurable, plus élevé en CI

Le timeout Cuprite est à 5s mais sous charge CI c'est parfois insuffisant pour les
interactions Turbo/Stimulus.

**Fichier :** `spec/support/configure_javascript_driver.rb`

```ruby
# Avant
Capybara.default_max_wait_time = 5

# Après
Capybara.default_max_wait_time = Integer(ENV.fetch('CAPYBARA_WAIT_TIME', 5))
```

**Fichier :** workflow CI GitHub Actions — ajouter `CAPYBARA_WAIT_TIME: 8`

## Ordre d'implémentation

1. **Tâche 2** ✅ (garde nil ligne 211) — correctif trivial, 1 ligne
2. **Tâche 3** ✅ (vérification post-login) — détection précoce, aide au debug
3. **Tâche 4** ✅ → remplacée par la piste A (voir ci-dessous)
4. **Tâche 5** ✅ (wait time CI) — filet de sécurité pour le rendu
5. **Tâche 1** ✅ — pistes A + D implémentées

## Résumé pour review (description PR)

### Problème

~30% des runs CI sur develop échouaient à cause de tests Cucumber flaky : à chaque
run, 1 scénario aléatoire sur ~533 échouait, obligeant à relancer manuellement. Ces
échecs tombaient dans 5 catégories, toutes liées à la même cause racine.

### Cause racine

Les scénarios `@javascript` utilisaient la stratégie `DatabaseCleaner :truncation`
pour partager les données entre le thread de test et le serveur Puma (qui tourne dans
un thread séparé). Le problème : entre deux scénarios, le `TRUNCATE TABLE` pouvait
s'exécuter pendant que Puma traitait encore une requête résiduelle. Résultat :
des tables tronquées en plein milieu d'un traitement, des records fantômes, des
sessions perdues, des `nil` inexpliqués.

### Solution principale : `pin_connection!(true)`

**Fichier clé : `features/support/env.rb`**

On remplace la stratégie `truncation` par `pin_connection!(true)` (API Rails 8.1,
utilisée en interne par les system tests Rails). Ce mécanisme force le pool de
connexions à retourner **la même connexion DB** au thread de test et au thread Puma.
Un mutex garantit qu'un seul thread utilise la connexion à la fois.

Conséquence : tous les scénarios (JS ou non) utilisent maintenant la stratégie
`:transaction`. Le cleanup se fait par `ROLLBACK` — atomique, instantané, sans race
condition. La truncation est complètement éliminée.

```ruby
# Avant : truncation pour @javascript → race condition
Before('@javascript') do
  DatabaseCleaner.strategy = :truncation
end

# Après : connexion partagée + transaction pour tous
Before('@javascript') do
  ActiveRecord::Base.connection_pool.pin_connection!(true)
end
```

### Autres corrections

**Helper `last_authorization_request`** — Les 30 occurrences de
`AuthorizationRequest.last` éparpillées dans les step definitions sont remplacées par
un helper centralisé qui : (1) retourne `@authorization_request` si défini, (2) fait
un `.order(:created_at).last` sinon, (3) raise un message explicite si nil. Avant,
un `.last` retournant nil produisait un `NoMethodError` cryptique plusieurs lignes
plus loin.

**Guard `current_user!`** — Un appel `current_user.email` non gardé (ligne 211 de
`authorization_requests_steps.rb`) pouvait crasher avec `NoMethodError` quand
`current_user` était nil. Remplacé par `current_user!.email` qui donne un message
clair.

**Vérification post-login** — Le step `je me connecte` vérifie maintenant que le
login a réussi. Si la page affiche encore « S'identifier avec ProConnect » après le
clic, un `raise` explicite est levé immédiatement, au lieu de laisser le scénario
continuer avec une session invalide et produire une erreur incompréhensible plus tard.

**`CAPYBARA_WAIT_TIME` configurable** — Le `default_max_wait_time` de Capybara est
maintenant configurable via variable d'environnement. Valeur par défaut : 5s. Sur la
CI (`.github/workflows/test.env`) : 8s, pour absorber la latence sous charge.

### Fichiers modifiés

| Fichier | Changement |
|---------|-----------|
| `features/support/env.rb` | `pin_connection!(true)`, suppression truncation |
| `features/support/authorization_request_helpers.rb` | Helper `last_authorization_request` |
| `features/step_definitions/authorization_requests_steps.rb` | 20× `.last` → helper, `current_user!` |
| `features/step_definitions/authorization_steps.rb` | 5× `.last` → helper |
| `features/step_definitions/messages_steps.rb` | 1× `.last` → helper |
| `features/step_definitions/organizations_steps.rb` | 1× `.last` → helper |
| `features/step_definitions/admin_steps.rb` | 1× `.last` → helper |
| `features/step_definitions/integrity_stepts.rb` | 1× `.last` → helper |
| `features/step_definitions/login_steps.rb` | Vérification post-login |
| `features/support/applicant_authorization_request_helpers.rb` | 1× `.last` → helper |
| `spec/support/configure_javascript_driver.rb` | `CAPYBARA_WAIT_TIME` configurable |
| `.github/workflows/test.env` | `CAPYBARA_WAIT_TIME=8` |

### Points d'attention pour la review

- `pin_connection!` est une API `:nodoc:` de Rails (non documentée publiquement),
  mais stable et utilisée par `ActiveRecord::TestFixtures` depuis Rails 7.1. Si
  l'API change dans une future version de Rails, l'erreur sera explicite (méthode
  non trouvée) et facile à corriger.
- Le helper `last_authorization_request` est un refactoring mécanique : chaque
  remplacement est identique. Le diff est volumineux mais le changement est simple.
- Aucun changement de comportement applicatif. Seul le code de test est modifié.

### Résultats

**Avant :** ~30% des runs CI échouaient (6/20), nécessitant des relances manuelles.

**Après :** 5 runs CI consécutifs, tous verts (0/5 en échec).
