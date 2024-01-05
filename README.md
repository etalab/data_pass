[![Continuous Deployment](https://github.com/etalab/data_pass/actions/workflows/continuous-deployment.yaml/badge.svg)](https://github.com/etalab/data_pass/actions/workflows/continuous-deployment.yaml)
[![Continuous Integration](https://github.com/etalab/data_pass/actions/workflows/test.yaml/badge.svg)](https://github.com/etalab/data_pass/actions/workflows/test.yaml)

# DataPass

L'outil de gestion des habilitations juridiques pour les données à accès restreint.

Version en ligne:
[https://datapass-reborn.onrender.com/](https://datapass-reborn.onrender.com/)
(basé sur le dernier commit de `main`)

Les comptes disponibles en simili-production (couple email/password sur
MonComptePro) :

* `user@yopmail.com` / `user@yopmail.com`: simple demandeur qui possède
    plusieurs habilitations sur
    la première organisation de liste (Commune de Clamart)
* `api-entreprise@yopmail.com` / `api-entreprise@yopmail.com`: instructeur pour
    API Entreprise, sans habilitation

Le lien pour l'instruction: [https://datapass-reborn.onrender.com/instruction](https://datapass-reborn.onrender.com/instruction)

A noter qu'à chaque déploiement la base de données est vidée et re-remplie avec
les seeds disponible [ici](app/lib/seeds.rb)

# Requirements

* ruby 3.3.0
* postressql >= 13
* (optional) npm (for [standardjs](https://standardjs.com/))

## Install

Ask for the production master key to a colleague
(`config/credentials/production.key`)

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
rails s
```

Then go to [http://localhost:3000](http://localhost:3000)

For mailer preview: [http://localhost:3000/rails/mailers](http://localhost:3000/rails/mailers)

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

## Documentation

* [Conception technique/métier](./docs/conception.md)
* [Ajout d'un nouveau fournisseur](./docs/new_provider.md)
* [Design System](./docs/design.md)

## Ressources externes

* [(Pad) DataPase Reborn conception](https://pad.incubateur.net/laoh-IYETHyUfzUvK7Mjmw?both)
* [(Pad) DataPass vs DS](https://pad.incubateur.net/KXZUoUBiQhqs6WwPUWGWLA?both)
