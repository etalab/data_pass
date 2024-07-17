[![Continuous Deployment](https://github.com/etalab/data_pass/actions/workflows/continuous-deployment.yaml/badge.svg)](https://github.com/etalab/data_pass/actions/workflows/continuous-deployment.yaml)
[![Continuous Integration](https://github.com/etalab/data_pass/actions/workflows/test.yaml/badge.svg)](https://github.com/etalab/data_pass/actions/workflows/test.yaml)

# DataPass

L'outil de gestion des habilitations juridiques pour les données à accès restreint.

Version en ligne:
[https://sandbox.v2.datapass.api.gouv.fr/](https://sandbox.v2.datapass.api.gouv.fr/)

Les comptes disponibles en simili-production (couple email/password sur
MonComptePro) :

* `user@yopmail.com` / `user@yopmail.com`: simple demandeur qui possède
    plusieurs habilitations sur
    la première organisation de liste (Commune de Clamart)
* `api-entreprise@yopmail.com` / `api-entreprise@yopmail.com`: instructeur pour
    API Entreprise, sans habilitation

Le lien pour l'instruction: [https://sandbox.v2.datapass.api.gouv.fr/instruction](https://sandbox.v2.datapass.api.gouv.fr/instruction)

A noter qu'à chaque déploiement la base de données est vidée et re-remplie avec
les seeds disponible [ici](app/lib/seeds.rb)

# Requirements

* ruby 3.3.2
* postressql >= 13
* (optional) npm (for [standardjs](https://standardjs.com/))

## Install

Ask for the sandbox/staging/production master key to a colleague
(`config/credentials/*.key`)

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

### Avec un sous-domaine référencé

Il est possible de restreindre l'application à un sous-ensemble de type
d'habilitation à travers un sous nom de domaine. Cela permet de restreindre les
demandeurs à ce sous-ensemble.

Par exemple pour API Entreprise: [http://api-entreprise.localtest.me:3000/](http://api-entreprise.localtest.me:3000/)

Il est possible de bypass le login via MonComptePro de cette manière en local :
[http://api-entreprise.localtest.me:3000/local-sign-in?email=api-entreprise@yopmail.com](http://api-entreprise.localtest.me:3000/local-sign-in?email=api-entreprise@yopmail.com)

## Tests

With docker:

```sh
# Unit
make tests
# E2E
make e2e
```

Without docker:

```sh
# Unit
bundle exec rspec
# Unit with coverage
COVERAGE=true bundle exec rspec
# E2E
bundle exec cucumber
# E2Ewith coverage
COVERAGE=true bundle exec cucumber
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

* [Conception technique/métier](./docs/conception.md)
* [Ajout d'un nouveau fournisseur](./docs/new_provider.md)
* [Design System](./docs/design.md)
* [Migration de l'ancienne stack](./app/migration/)

## Ressources externes

* [(Pad) DataPase Reborn conception](https://pad.incubateur.net/laoh-IYETHyUfzUvK7Mjmw?both)
* [(Pad) DataPass vs DS](https://pad.incubateur.net/KXZUoUBiQhqs6WwPUWGWLA?both)
