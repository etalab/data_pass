# Rejoue le moteur d’éligibilité (EntityEligibility::Engine) sur des entités
# réelles extraites de Metabase, et produit des statistiques de couverture au
# format JSON, consommées par la vue `index.html` du même dossier.
#
# Usage (charge l’environnement Rails pour utiliser le vrai moteur) :
#
#   bundle exec ruby docs/moteur_eligibilite/stats.rb
#   # ou, avec Docker :
#   docker compose run --rm --entrypoint="" web bundle exec ruby docs/moteur_eligibilite/stats.rb
#
# La source CSV (export public Metabase) est surchargeable :
#
#   CSV_URL="https://…/xxx.csv" bundle exec ruby docs/moteur_eligibilite/stats.rb

require_relative '../../config/environment' unless defined?(Rails) && Rails.application

require 'open-uri'
require 'csv'
require 'json'

DEFAULT_CSV_URL =
  'https://metabase.entreprise.api.gouv.fr/public/question/46147ea2-7a03-4190-aa80-6f8bc0b3b5cc.csv'.freeze

# Le moteur résout la règle sur la classe de démarche : on lui fournit un
# formulaire minimal qui n’expose que ce dont il a besoin.
FormStub = Struct.new(:authorization_request_class)

def verdict_for(organization, type)
  EntityEligibility::Engine.new(
    organization:,
    authorization_request_form: FormStub.new(type.constantize),
  ).verdict
end

def short_type(type)
  type.to_s.delete_prefix('AuthorizationRequest::')
end

csv_url = ENV.fetch('CSV_URL', DEFAULT_CSV_URL)
warn "Téléchargement du CSV : #{csv_url}"
csv = CSV.parse(URI.parse(csv_url).open.read, headers: true)
warn "#{csv.size} lignes chargées, exécution du moteur…"

entities = csv.filter_map do |row|
  insee_payload = JSON.parse(row.fetch('insee_payload'))
  organization = Organization.new(insee_payload:)
  verdict = verdict_for(organization, row.fetch('type_formulaire'))

  {
    demande_id: row['demande_id']&.to_i,
    type: short_type(row['type_formulaire']),
    form_uid: row['form_uid'],
    etat: row['etat'],
    siret: row['siret'],
    raison_sociale: row['raison_sociale'],
    categorie_juridique: organization.categorie_juridique,
    entity_type: organization.entity_type.to_s,
    activite_principale: organization.activite_principale,
    status: verdict.status.to_s,
    reason: verdict.reason&.to_s,
  }
rescue StandardError => e
  warn "Ligne ignorée (demande #{row['demande_id']}) : #{e.class} #{e.message}"
  nil
end

def tally(entities, key)
  entities
    .each_with_object(Hash.new(0)) { |entity, acc| acc[entity[key]] += 1 }
    .sort_by { |_value, count| -count }
    .to_h
end

def top(entities, key, limit = 25)
  tally(entities.reject { |e| e[key].nil? }, key).first(limit).to_h
end

statuses = EntityEligibility::Verdict::STATUSES.map(&:to_s)

PREFERRED_ETATS = %w[validated submitted changes_requested revoked refused archived draft].freeze
present_etats = entities.map { |entity| entity[:etat] }.uniq
etats = (PREFERRED_ETATS & present_etats) + (present_etats - PREFERRED_ETATS)

# Matrice de confusion : verdict du moteur (lignes) × décision humaine (colonnes).
# Les incohérences (ex. inéligible pourtant validé) sont des faux positifs à traquer.
matrix = statuses.index_with do |status|
  rows = entities.select { |entity| entity[:status] == status }
  etats.index_with { |etat| rows.count { |entity| entity[:etat] == etat } }
end

by_type = entities.group_by { |entity| entity[:type] }.transform_values do |rows|
  {
    total: rows.size,
    by_status: statuses.index_with { |status| rows.count { |r| r[:status] == status } },
    by_reason: tally(rows.reject { |r| r[:reason].nil? }, :reason),
  }
end

stats = {
  generated_at: Time.now.utc.iso8601,
  source: csv_url,
  total: entities.size,
  statuses:,
  etats:,
  matrix:,
  by_status: statuses.index_with { |status| entities.count { |e| e[:status] == status } },
  by_type:,
  by_reason: tally(entities.reject { |e| e[:reason].nil? }, :reason),
  signals: {
    by_entity_type: tally(entities, :entity_type),
    top_categorie_juridique: top(entities, :categorie_juridique),
    top_activite_principale: top(entities, :activite_principale),
  },
  entities:,
}

output = File.join(__dir__, 'stats.json')
File.write(output, JSON.pretty_generate(stats))

warn "\nÉcrit : #{output}"
warn "Total : #{stats[:total]}"
stats[:by_status].each { |status, count| warn format('  %-18s %d', status, count) }
