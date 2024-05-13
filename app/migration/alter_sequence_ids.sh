#!/bin/bash

bundle exec rails runner "
ActiveRecord::Base.connection.execute(\"select setval('authorization_requests_id_seq', 87000, true);\")
"
