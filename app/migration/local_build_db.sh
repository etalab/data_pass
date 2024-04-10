#!/bin/bash

delete_db='false'

LOCAL=true time bundle exec rails runner "ImportDataInLocalDb.new.perform(delete_db_file: $delete_db)"
