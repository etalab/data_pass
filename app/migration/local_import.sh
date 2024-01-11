#!/bin/bash

LOCAL=true time bundle exec rails runner "MainImport.new.perform"
