# Tests en parallèle

La CI exécute la suite en parallèle via le gem [`parallel_tests`](https://github.com/grosser/parallel_tests) — voir [`.github/workflows/test.yaml`](../../.github/workflows/test.yaml) : RSpec sur 4 groupes, Cucumber sur 6 groupes.

Le wrapper `bin/test-parallel` permet de lancer la même chose en local, en s'appuyant sur les mêmes binstubs (`parallel_rspec` / `parallel_cucumber`) et la même variable d'environnement `TEST_ENV_NUMBER` que la CI.

## Comment ça fonctionne

`parallel_tests` lance N processus de test, chacun reçoit un sous-ensemble des fichiers à exécuter et une variable `TEST_ENV_NUMBER` distincte (vide pour le premier, `2`, `3`, … pour les suivants). Le gem ne touche pas à `ActiveRecord` — c'est à l'application d'utiliser cette variable. Côté DataPass, `config/database.yml` interpole `TEST_ENV_NUMBER` après le nom de base de test :

```yaml
test:
  database: <%= ENV.fetch('DATABASE_TEST_NAME') { 'data_pass_test' } %><%= ENV['TEST_ENV_NUMBER'] %>
```

Résultat : à partir de `DATABASE_TEST_NAME` (défini dans `.env.local`), le suffixe `TEST_ENV_NUMBER` produit `data_pass_test`, `data_pass_test2`, `data_pass_test3`, … Chaque processus a donc sa propre base, ce qui supprime la contention DB qui rend les tests non-déterministes en exécution concurrente sans Docker (voir le warning dans le README). Sans cette interpolation, les N processus taperaient tous sur la même base et provoqueraient des deadlocks au TRUNCATE de fin de test.

## Setup initial (une fois par worktree)

```sh
bin/test-parallel setup
```

Crée toutes les bases de tests parallèles et y charge le schéma courant. À rejouer après chaque modification de schéma (nouvelle migration), sinon les processus 2+ tourneront sur un schéma périmé.

Pour supprimer ces bases (quand le worktree est retiré, par exemple) :

```sh
bin/test-parallel drop
```

Les tâches `parallel:create` / `parallel:load_schema` sont fournies par le Railtie de `parallel_tests`. Le gem étant déclaré dans `group :test` du Gemfile, ses tâches ne sont visibles qu'avec `RAILS_ENV=test` — d'où le préfixe dans `bin/test-parallel setup`.

## Lancer la suite

```sh
bin/test-parallel              # rspec + cucumber, nombre de process auto-détecté
bin/test-parallel rspec        # rspec seul
bin/test-parallel cucumber     # cucumber seul
bin/test-parallel -n 4         # force 4 process (rspec + cucumber)
```

Sans `-n`, le nombre de processus est déterminé par `parallel_tests` à partir des cœurs CPU disponibles.

Le wrapper exécute toujours toute la suite (`spec/` ou `features/`). Pour cibler un fichier précis, repasser sur les commandes classiques (`bundle exec rspec spec/path/to/file_spec.rb`) — le parallèle n'apporte rien à ce niveau-là.

## Flag `-r N` (retry cucumber, opt-in)

Par défaut, aucun retry n'est appliqué. Raisons :

- La CI ne retry pas non plus — garder le même comportement en local évite qu'un scénario flaky passe localement et casse en CI (ou inversement).
- Un retry masque les flakies sans les remonter : si un scénario échoue 1 fois sur 3, on veut le savoir tôt pour l'attaquer, pas le découvrir des semaines plus tard en CI.

Le flag `-r N` reste utile quand on veut explicitement vérifier qu'un échec donné est dû à un flakie connu, sans avoir à le rejouer à la main :

```sh
bin/test-parallel cucumber -r 2
```

Avec `-r`, les scénarios encore en échec après les retries sont écrits dans `tmp/cucumber-rerun.txt`. La sous-commande `rerun` les rejoue (avec `--retry 2`, cette fois en série) :

```sh
bin/test-parallel rerun
```

`tmp/cucumber-rerun.txt` est régénéré à chaque run avec `-r`, et n'est jamais touché par les runs sans `-r`.

## Cohérence CI / local

| Aspect           | CI                                    | Local                                 |
|------------------|---------------------------------------|---------------------------------------|
| Binstub RSpec    | `parallel_rspec -n 4 --only-group N`  | `parallel_rspec -n COUNT`             |
| Binstub Cucumber | `parallel_cucumber -n 6 --only-group N` | `parallel_cucumber -n COUNT`        |
| Variable d'env   | `TEST_ENV_NUMBER`                     | `TEST_ENV_NUMBER`                     |
| Retry            | non                                   | opt-in via `-r N`                     |

La différence principale : la CI shard la suite en `--only-group` sur plusieurs runners GitHub Actions, le local lance tous les groupes sur la même machine.
