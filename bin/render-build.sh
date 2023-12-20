#!/usr/bin/env bash
# exit on error
set -o errexit

bundle install
./bin/rails assets:precompile
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 ./bin/rails db:schema:load
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 ./bin/rails db:seed:replant
