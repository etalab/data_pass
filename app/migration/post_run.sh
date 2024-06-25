#!/bin/bash

## TODO TO CHANGE
RAILS_ENV=production
## END TODO

export RAILS_ENV

sudo rm /var/www/html/maintenance_datapass_$RAILS_ENV.html
sudo service nginx reload
