[![ci](https://github.com/etalab/data_pass/actions/workflows/test.yaml/badge.svg)](https://github.com/etalab/data_pass/actions/workflows/test.yaml)

# DataPass

L'outil de gestion des habilitations juridiques pour les données à accès restreint.

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

* [Design System](./docs/design.md)
