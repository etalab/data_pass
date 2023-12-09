DOCKER-RUN = docker-compose run --rm --entrypoint=""
BUNDLE-EXEC = bundle exec

build:
	docker-compose build

up:
	docker-compose up web db redis

down:
	docker-compose down

.PHONY: db
db:
	$(DOCKER-RUN) db psql -U postgres -h db -d development

sh:
	$(DOCKER-RUN) web $(BUNDLE-EXEC) bash

lint:
	$(DOCKER-RUN) web $(BUNDLE-EXEC) rubocop

guard:
	docker-compose up -d chrome
	$(DOCKER-RUN) web $(BUNDLE-EXEC) guard

tests:
	docker-compose up -d chrome
	$(DOCKER-RUN) web $(BUNDLE-EXEC) rspec

console:
	$(DOCKER-RUN) web bin/rails console

restart:
	docker-compose exec web touch tmp/restart.txt

replant:
	$(DOCKER-RUN) web bin/rails db:seed:replant
