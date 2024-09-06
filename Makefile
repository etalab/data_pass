ifeq ($(shell which docker-compose),)
	DOCKER-COMPOSE = docker compose
else
	DOCKER-COMPOSE = docker-compose
endif
DOCKER-RUN = $(DOCKER-COMPOSE) run --rm --entrypoint=""
BUNDLE-EXEC = bundle exec

build:
	$(DOCKER-COMPOSE) build

up:
	$(DOCKER-COMPOSE) up web db redis worker

down:
	$(DOCKER-COMPOSE) down

.PHONY: db
db:
	$(DOCKER-RUN) db psql -U postgres -h db -d development

sh:
	$(DOCKER-RUN) web $(BUNDLE-EXEC) bash

lint:
	$(DOCKER-RUN) web $(BUNDLE-EXEC) rubocop

fix-lint:
	$(DOCKER-RUN) web $(BUNDLE-EXEC) rubocop -A

js-lint:
	$(DOCKER-RUN) web standard app/javascript

yaml-lint:
	$(DOCKER-RUN) web prettier "config/**/*.yaml" "config/**/*.yml" "!config/cucumber.yml"

fix-yaml-lint:
	$(DOCKER-RUN) web prettier --write "config/**/*.yaml" "config/**/*.yml" "!config/cucumber.yml"

security:
	$(DOCKER-RUN) web $(BUNDLE-EXEC) ./bin/brakeman

guard:
	$(DOCKER-COMPOSE) up -d chrome
	$(DOCKER-RUN) web $(BUNDLE-EXEC) guard

tests:
	$(DOCKER-COMPOSE) up -d chrome
	$(DOCKER-RUN) web $(BUNDLE-EXEC) rspec

e2e:
	$(DOCKER-COMPOSE) up -d chrome
	$(DOCKER-RUN) web $(BUNDLE-EXEC) cucumber

console:
	$(DOCKER-RUN) web bin/rails console

restart:
	$(DOCKER-COMPOSE) exec web touch tmp/restart.txt

replant:
	$(DOCKER-RUN) web bin/rails db:seed:replant

prepare_db:
	$(DOCKER-RUN) web bin/rails db:schema:load
