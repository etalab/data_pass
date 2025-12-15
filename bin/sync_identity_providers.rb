#!/usr/bin/env ruby

require 'csv'
require 'yaml'
require 'fileutils'

CSV_URL = 'https://grist.numerique.gouv.fr/o/docs/api/docs/wYRXMtwGCK3UGL9c9EaW2R/download/csv?viewSection=1&tableId=Table1&activeSortSpec=%5B%5D&filters=%5B%5D&linkingFilter=%7B%22filters%22%3A%7B%7D%2C%22operations%22%3A%7B%7D%7D'
CSV_PATH = 'tmp/identity_providers.csv'
CONFIG_PATH = 'config/identity_providers.yml'

puts 'Downloading CSV from Grist...'
FileUtils.mkdir_p('tmp')

system("curl -s '#{CSV_URL}' -o #{CSV_PATH}")

unless File.exist?(CSV_PATH)
  puts "Error downloading CSV"
  exit 1
end

puts "CSV downloaded to #{CSV_PATH}"

puts 'Parsing CSV and updating configuration...'
config = YAML.load_file(CONFIG_PATH, aliases: true)

csv_content = File.read(CSV_PATH)
csv_data = CSV.parse(csv_content, headers: true)

new_providers = {}

csv_data.each do |row|
  uid = row['uid']
  next unless uid

  network = row['Réseau']
  if network == 'rie'
    next
  end

  provider = {
    'name' => row['Nom du FI'],
    'choose_organization_on_sign_in' => row['choose_organization_on_sign_in'] == 'true',
    'siret_verified' => row['siret_verified'] == 'true',
    'can_link_to_organizations' => row['can_link_to_organizations'] == 'true'
  }

  new_providers[uid] = provider
end

config['shared'] = new_providers

File.write(CONFIG_PATH, YAML.dump(config))
puts "\nConfiguration updated in #{CONFIG_PATH}"
puts "Updated #{new_providers.size} identity providers"
