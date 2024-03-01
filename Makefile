DOCKER-RUN = docker-compose run --rm --entrypoint=""
BUNDLE-EXEC = bundle exec

build:
	docker-compose build

up:
	docker-compose up web db redis worker

down:
	docker-compose down

.PHONY: db
db:
	$(DOCKER-RUN) db psql -U postgres -h db -d development

sh:
	$(DOCKER-RUN) web $(BUNDLE-EXEC) bash

lint:
	$(DOCKER-RUN) web $(BUNDLE-EXEC) rubocop

js-lint:
	$(DOCKER-RUN) web standard app/javascript

guard:
	docker-compose up -d chrome
	$(DOCKER-RUN) web $(BUNDLE-EXEC) guard

tests:
	docker-compose up -d chrome
	$(DOCKER-RUN) web $(BUNDLE-EXEC) rspec

e2e:
	docker-compose up -d chrome
	$(DOCKER-RUN) web $(BUNDLE-EXEC) cucumber

console:
	$(DOCKER-RUN) web bin/rails console

restart:
	docker-compose exec web touch tmp/restart.txt

replant:
	$(DOCKER-RUN) web bin/rails db:seed:replant
