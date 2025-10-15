# rubocop:disable Rails/Output
require 'csv'

puts 'Generating the match of datapass v1 ids with demande & habilitation v2 ids...'

# Read v1_ids from CSV file
csv_file_path = ARGV[0] || '/tmp/datapass_v1_ids.csv'

unless File.exist?(csv_file_path)
  puts "❌ CSV file not found: #{csv_file_path}"
  puts "Usage: ruby match_ids_from_csv.rb [path_to_csv_file]"
  exit 1
end

puts "📁 Reading v1_ids from: #{csv_file_path}"

v1_ids = []
CSV.foreach(csv_file_path, headers: true) do |row|
  id = row[0]&.strip&.to_i
  v1_ids << id if id > 0
end

puts "📊 Loaded #{v1_ids.length} v1_ids from CSV file"

matched_demandes = AuthorizationRequest.where(id: v1_ids).includes(:authorizations)
matched_habilitations = Authorization.where(id: v1_ids).includes(:request)

matched_demande_ids = matched_demandes.index_by(&:id)
matched_habilitation_ids = matched_habilitations.index_by(&:id)

matched_ids = []
unmatched_v1_ids = []
ambiguous_demandes = []

v1_ids.each_with_index do |v1_id, _index|
  if matched_habilitation_ids.key?(v1_id)
    habilitation = matched_habilitation_ids[v1_id]
    demande = habilitation.request
    matched_ids << [v1_id, demande.id, habilitation.id]

  elsif matched_demande_ids.key?(v1_id)
    demande = matched_demande_ids[v1_id]
    habilitations = demande.authorizations

    if habilitations.length.positive?
      ambiguous_demandes << [v1_id, demande]
      matched_ids << [v1_id, demande.id, "#{habilitations.length} habilitations found : #{habilitations.map(&:id).join(', ')}"]
    else
      matched_ids << [v1_id, demande.id, nil]
    end
  else
    unmatched_v1_ids << v1_id
    matched_ids << [v1_id, nil, nil]
  end
end

ambiguous_demandes_left = []

if ambiguous_demandes.any?
  puts "Processing #{ambiguous_demandes.length} ambiguous demandes : #{ambiguous_demandes.map(&:first).join(', ')}"
  matched_authorizations_ids = matched_ids.pluck(2)

  ambiguous_demandes.each do |v1_id, demande|
    # Remove the authorizations that are already matched
    unmatched_authorizations = demande.authorizations.reject { |authorization| matched_authorizations_ids.include?(authorization.id) }
    matched_index = matched_ids.find_index { |row| row[0] == v1_id }

    if unmatched_authorizations.length > 1
      puts "⚠️ Found #{unmatched_authorizations.length} unmatched authorizations for ambiguous demande #{demande.id}"
      ambiguous_demandes_left << [v1_id, demande]

    elsif unmatched_authorizations.length == 1
      # Find and replace the row in matched_ids with the correct v1_id and demande.id
      matched_ids[matched_index] = [v1_id, demande.id, unmatched_authorizations.first.id]
    else
      # It's a new ongoing demande (with previous existing habilitations already matched)
      matched_ids[matched_index] = [v1_id, demande.id, nil]
    end
  end
end

if ambiguous_demandes_left.any?
  puts "⚠️ Found #{ambiguous_demandes_left.length} ambiguous demandes left"
  CSV.open('/tmp/ambiguous_demandes_left.csv', 'w') do |csv|
    csv << %w[datapass_v1_id demande_v2_id]
    ambiguous_demandes_left.each do |v1_id, demande|
      csv << [v1_id, demande.id]
    end
  end
  puts "📄 Ambiguous demandes written to: /tmp/ambiguous_demandes_left.csv"
else
  puts '✅ All good ! No ambiguous demandes left.'
end

puts "\n"

# Log unmatched v1_ids
if unmatched_v1_ids.any?
  puts "❌ Found #{unmatched_v1_ids.length} unmatched v1_ids"
  CSV.open('/tmp/unmatched_v1_ids.csv', 'w') do |csv|
    csv << ['datapass_v1_id']
    unmatched_v1_ids.each do |v1_id|
      csv << [v1_id]
    end
  end
  puts "📄 Unmatched v1_ids written to: /tmp/unmatched_v1_ids.csv"
end

#  Check extra authorizations and demandes and log them
matched_demandes_ids = matched_ids.pluck(1).compact.uniq
matched_authorizations_ids = matched_ids.pluck(2).compact.uniq

dgfip_requests = AuthorizationRequest
  .where.not(state: %w[draft archived])
  .where("authorization_requests.form_uid LIKE '%-production' OR authorization_requests.form_uid LIKE '%-sandbox' OR authorization_requests.form_uid LIKE '%-editeur'")

extra_demandes = dgfip_requests.where.not(id: matched_demandes_ids).order('authorization_requests.id ASC')
extra_authorizations = Authorization.joins(:request).merge(dgfip_requests).where.not(id: matched_authorizations_ids).order('authorizations.id ASC')

if extra_demandes.any?
  puts "📊 Found #{extra_demandes.length} extra demandes"
  CSV.open('/tmp/extra_demandes.csv', 'w') do |csv|
    csv << %w[demande_v2_id demande_state demande_last_submitted_at]
    extra_demandes.each do |demande|
      csv << [demande.id, demande.state, demande.last_submitted_at]
    end
  end
  puts "📄 Extra demandes written to: /tmp/extra_demandes.csv"
end

if extra_authorizations.any?
  puts "📊 Found #{extra_authorizations.length} extra authorizations"
  CSV.open('/tmp/extra_authorizations.csv', 'w') do |csv|
    csv << %w[demande_v2_id habilitation_v2_id demande_state habilitation_state habilitation_created_at]
    extra_authorizations.each do |habilitation|
      csv << [habilitation.request.id, habilitation.id, habilitation.request.state, habilitation.state, habilitation.created_at]
    end
  end
  puts "📄 Extra authorizations written to: /tmp/extra_authorizations.csv"
end

puts "\n"

# Output results to CSV
output_file = '/tmp/matched_ids_result.csv'
CSV.open(output_file, 'w') do |csv|
  csv << %w[datapass_v1_id demande_v2_id habilitation_v2_id]

  matched_ids.each do |row|
    csv << row
  end
end

puts "✅ Results written to: #{output_file}"
puts "📊 Total matched records: #{matched_ids.length}"

# rubocop:enable Rails/Output 