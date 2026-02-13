[![Continuous Deployment](https://github.com/etalab/data_pass/actions/workflows/continuous-deployment.yaml/badge.svg)](https://github.com/etalab/data_pass/actions/workflows/continuous-deployment.yaml)
[![Continuous Integration](https://github.com/etalab/data_pass/actions/workflows/test.yaml/badge.svg)](https://github.com/etalab/data_pass/actions/workflows/test.yaml)

# DataPass

L'outil de gestion des habilitations juridiques pour les données à accès restreint.

Version en ligne:
[https://sandbox.v2.datapass.api.gouv.fr/](https://sandbox.v2.datapass.api.gouv.fr/)

Les comptes disponibles en simili-production (couple email/password sur
ProConnect) :

Via le fournisseur d'identité ProConnect (le choix de l'organisation s'effectue
en dehors de DataPass) :

- `user@yopmail.com` / `user@yopmail.com`: simple demandeur qui possède
  plusieurs habilitations sur
  la première organisation de liste (Commune de Clamart)
- `api-entreprise@yopmail.com` / `api-entreprise@yopmail.com`: instructeur pour
  API Entreprise, sans habilitation
- `datapass@yopmail.com` pour un compte admin / toute instruction

Via un fournisseur d'identité fictif, qui est configuré pour sélectionner /
ajouter des organisations :

- `whatever@fia1.fr` (pas de mot de passe) : simple demandeur qui possède 2
    demandes sur la DINUM (lien avec l'organisation non vérifiée). Cet usager
    est rattaché à la commune de Clamart et le lien avec l'organisation est
    vérifié. Cet usager peut se rattacher à une organisation.
- `whatever@fia2.fr` (pas de mot de passe) : simple demandeur sans demande.
  Cet usager ne peut pas se rattacher à une nouvelle organisation via DataPass.

La conséquence pour le compte ci-dessus est que l'usager ne peut pas consulter
les autres demandes de la DINUM.

Le lien pour l'instruction: [https://sandbox.v2.datapass.api.gouv.fr/instruction](https://sandbox.v2.datapass.api.gouv.fr/instruction)

A noter qu'à chaque déploiement la base de données est vidée et re-remplie avec
les seeds disponible [ici](app/lib/seeds.rb)

# Requirements

- ruby 3.4.7
- postgresql >= 13
- (optional) npm (for [standardjs](https://standardjs.com/) and [prettier](https://prettier.io/))

## Install

Ask for the sandbox/staging/production master key to a colleague
(`config/credentials/*.key`)

You also need to setup environment variables, you can copy from
`config/env.example` within `.env.local` file and change them as needed.
There are not mandatory to run most of the features, only for INSEE fetching
for instructor drafts.

With docker:

```sh
make build
```

Without docker:

```sh
./bin/setup
# Optional, for standardjs
npm install standard --global
```

## Development

With docker:

```sh
make up
```

Check [Makefile](Makefile) for all commands

Without docker:

```sh
./bin/local_run.sh
```

Then go to [http://localhost:3000](http://localhost:3000)

For mailer preview: [http://localhost:3000/rails/mailers](http://localhost:3000/rails/mailers)

### Worktrees

You can run multiple worktrees simultaneously, each with its own database and
web port. From the main worktree:

```sh
# Create a new worktree
bin/worktree-build ../my-worktree feature/my-feature 3001

# Reconfigure an existing worktree
bin/worktree-build --setup-only ../my-worktree 3001
```

Each worktree gets its own `.env.local` with isolated `DATABASE_DEVELOPMENT_NAME`,
`DATABASE_TEST_NAME`, `PORT`, and `ACTION_CABLE_CHANNEL_PREFIX`. Redis is shared.

Start each worktree independently with `bin/local_run.sh`.

### Avec un sous-domaine référencé

Il est possible de restreindre l'application à un sous-ensemble de type
d'habilitation à travers un sous nom de domaine. Cela permet de restreindre les
demandeurs à ce sous-ensemble.

Par exemple pour API Entreprise: [http://api-entreprise.localtest.me:3000/](http://api-entreprise.localtest.me:3000/)

Il est possible de bypass le login via ProConnect de cette manière en local :
[http://api-entreprise.localtest.me:3000/local-sign-in?email=api-entreprise@yopmail.com](http://api-entreprise.localtest.me:3000/local-sign-in?email=api-entreprise@yopmail.com)

## Tests

### With docker

Préparation de la base de données: `docker-compose run --rm web bundle exec rails db:create RAILS_ENV=test` (devrait avoir été lancé par `make build`)

Run les tests:

```sh
# Unit
make tests
# E2E
make e2e
```

Vous pouvez passer un dossier ou un fichier de test en argument (ex: `make tests spec/controllers`)

### Without docker

⚠️Il est déconseillé de run plus d'un test à la fois sans Docker car cela peut entrainer des échecs de tests.

```sh
# Unit
bundle exec rspec
# Unit with coverage
COVERAGE=true bundle exec rspec
# E2E
bundle exec cucumber
# E2Ewith coverage
COVERAGE=true bundle exec cucumber
# E2E in debugging mode
INSPECTOR=true bundle exec cucumber
```

## Static security

Through [Brakeman](https://github.com/presidentbeef/brakeman)

With docker:

```sh
make security
```

Without docker:

```sh
./bin/brakeman
```

## Deploy

```sh
./bin/deploy

# For sandbox, branch is optional
./bin/deploy-sandbox branch
```

## Tools for remote server

You have to be added on servers to use these binaries.

Usage: `bin/script [ENV]`

```
# `less` on logs
bin/explore-remote-logs
# remote rails console
bin/remote-console
# `tail -f` on logs
bin/stream-remote-logs
```

## Credentials

4 kind:

1. `production`, for main app ;
2. `sandbox`, for the sandbox ;
3. `staging`, for the staging (E2E tests with others apps) ;
4. `development`, for development/test.

## Documentations

Check [this link](./docs/README.md)

- [Conception technique/métier](./docs/conception.md)
- [Ajout d'un nouveau fournisseur](./docs/nouveau_type_d_habilitation.md)
- [Design System](./docs/design.md)
- [Migration de l'ancienne stack](./app/migration/)

## Ressources externes

- [(Pad) DataPase Reborn conception](https://pad.incubateur.net/laoh-IYETHyUfzUvK7Mjmw?both)
- [(Pad) DataPass vs DS](https://pad.incubateur.net/KXZUoUBiQhqs6WwPUWGWLA?both)
