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

* ruby 3.2.2
* postressql >= 13

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

## Tests

With docker:

```sh
make tests
```

Without docker:

```sh
bundle exec rspec
```

## Documentation

* [Ajout d'un nouveau fournisseur](./docs/new_provider.md)
* [Design System](./docs/design.md)
