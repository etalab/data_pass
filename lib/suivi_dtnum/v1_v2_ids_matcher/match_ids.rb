require 'csv'

puts "Generating the match of datapass v1 ids with demande & habilitation v2 ids..."

v1_ids = CSV.read('lib/suivi_dtnum/v1_v2_ids_matcher/datapass_v1_ids.csv', headers: true).map { |row| row['N° DataPass'] }

# Find AuthorizationRequests where raw_attributes_from_v1 contains any of the v1_ids
matching_requests_with_v1_id = AuthorizationRequest.where(
  "raw_attributes_from_v1::jsonb->>'id' IN (?)", v1_ids
).includes(:authorizations)
puts "Found #{matching_requests_with_v1_id.count} matching authorization_requests with v1_ids"


matching_requests_with_v1_previous_enrollment_id_ = AuthorizationRequest.where(
  "raw_attributes_from_v1::jsonb->>'previous_enrollment_id' IN (?)", v1_ids
).includes(:authorizations)
puts "Found #{matching_requests_with_v1_previous_enrollment_id_.count} matching authorization_requests with v1_previous_enrollment_id"


matching_requests_with_v1_copied_from_enrollment_id = AuthorizationRequest.where(
  "raw_attributes_from_v1::jsonb->>'copied_from_enrollment_id' IN (?)", v1_ids
).includes(:authorizations)
puts "Found #{matching_requests_with_v1_copied_from_enrollment_id.count} matching authorization_requests with v1_copied_from_enrollment_id"

# Create a hash of v1_id => [request, authorizations] for quick lookup
v1_to_demande_v2_map = {}
matching_requests_with_v1_id.each do |request|
  v1_id = JSON.parse(request.raw_attributes_from_v1)['id']
  v1_to_demande_v2_map[v1_id] = [request, request.authorizations]
end

# Create the result data as an array first
matched_ids = []
extra_authorizations_ids = []
row_with_no_authorization_id_equal_to_v1_id = []

v1_ids.each do |v1_id|
  if v1_to_demande_v2_map.key?(v1_id)
    request, authorizations = v1_to_demande_v2_map[v1_id]

    # Create a row for each authorization
    if authorizations.any?
      authorizations.each do |authorization|
        # keep the authorization with the same id as the v1_id
        if authorization.id == v1_id.to_i
          matched_ids << [v1_id, request.id, authorization.id]
        else
          # log the others as extra, they should not exist
          # TODO check if its "normal" because of a copy id or sandbox id before adding it to the extra authorizations ids
          extra_authorizations_ids << [v1_id, request.id, authorization.id, request.type]
        end

        # If no authorization was found with the same id as the v1_id, create a row with empty habilitation_v2_id to not skip a row
        unless authorizations.map(&:id).include? v1_id.to_i
          matched_ids << [v1_id, request.id, nil]
          authorizations.each do |authorization|
            row_with_no_authorization_id_equal_to_v1_id << [v1_id, request.id, authorization.id]
          end
        end
      end
    else
      # If no authorizations, create a row with empty habilitation_v2_id
      matched_ids << [v1_id, request.id, nil]
    end
  else
    # If no matching request found, create a row with only the v1_id
    # TODO actually we should not add it, we should have found it in the extra authorizations ids
    matched_ids << [v1_id, nil, nil]
  end
end

# Check for missing v1_ids
if matched_ids.length != v1_ids.length
  puts "\nWarning: Not all v1_ids were processed"
  puts "v1_ids.length: #{v1_ids.length}"
  puts "matched_ids.uniq.length: #{matched_ids.length}"

  # Find the missing v1_ids
  missing_v1_ids = v1_ids - matched_ids.uniq.map { |row| row[0] }
  puts "Missing v1_ids: #{missing_v1_ids.join(', ')}\n"
end

if row_with_no_authorization_id_equal_to_v1_id.any?
  puts "\nFound #{row_with_no_authorization_id_equal_to_v1_id.length} rows with no authorization id equal to v1_id:"
  row_with_no_authorization_id_equal_to_v1_id.each do |row|
    puts "v1_id: #{row[0]}, demande_v2_id: #{row[1]}, habilitation_v2_id: #{row[2]}"
  end
  puts "\n"
end


if extra_authorizations_ids.any?
  puts "Found #{extra_authorizations_ids.length} extra authorizations ids -> see extra_authorizations_ids.csv"

  CSV.open('lib/suivi_dtnum/v1_v2_ids_matcher/extra_authorizations_ids.csv', 'w') do |csv|
    csv << ['datapass_v1_id', 'demande_v2_id', 'habilitation_v2_id', 'demande_type']
    extra_authorizations_ids.each do |row|
      csv << row
    end
  end
end


# Output results to CSV
CSV.open('lib/suivi_dtnum/v1_v2_ids_matcher/matched_ids.csv', 'w') do |csv|
  csv << ['datapass_v1_id', 'demande_v2_id', 'habilitation_v2_id']

  matched_ids.each do |row|
    csv << row
  end
end
puts "Results written to matched_ids.csv\n\n"