require 'csv'

puts "Generating the match of datapass v1 ids with demande & habilitation v2 ids..."

v1_ids = CSV.read('lib/suivi_dtnum/v1_v2_ids_matcher/datapass_v1_ids.csv', headers: true).map { |row| row['N° DataPass'] }

# Find AuthorizationRequests where raw_attributes_from_v1 contains any of the v1_ids
matching_requests = AuthorizationRequest.where(
  "raw_attributes_from_v1::jsonb->>'id' IN (?)", v1_ids
).includes(:authorizations)

puts "Found #{matching_requests.count} matching authorization_requests"

# Create a hash of v1_id => [request, authorizations] for quick lookup
v1_to_v2_map = {}
matching_requests.each do |request|
  v1_id = JSON.parse(request.raw_attributes_from_v1)['id']
  v1_to_v2_map[v1_id] = [request, request.authorizations]
end

# Create the result data as an array first
results = []
matched_ids = []

v1_ids.each do |v1_id|
  if v1_to_v2_map.key?(v1_id)
    request, authorizations = v1_to_v2_map[v1_id]
    
    if authorizations.any?
      # Create a row for each authorization
      # Actually we do it only when the authorization has the same id as the v1_id, cause the others should not exit
      # (it's getting fixed in the next dump)
      authorizations_with_matching_id = authorizations.where(id: v1_id)
      
      if authorizations_with_matching_id.any?
        authorizations_with_matching_id.each do |authorization|
          results << [v1_id, request.id, authorization.id]
          matched_ids << v1_id
        end
      else
        # If no matching authorizations, create a row with empty habilitation_v2_id
        results << [v1_id, request.id, nil]
        matched_ids << v1_id
      end
    else
      # If no authorizations, create a row with empty habilitation_v2_id
      results << [v1_id, request.id, nil]
      matched_ids << v1_id
    end
  else
    # If no matching request found, create a row with only the v1_id
    results << [v1_id, nil, nil]
    matched_ids << v1_id
  end
end

# Check for missing v1_ids
if matched_ids.length != v1_ids.length
  puts "Warning: Not all v1_ids were processed"
  puts "v1_ids.length: #{v1_ids.length}"
  puts "matched_ids.uniq.length: #{matched_ids.length}"

  # Find the missing v1_ids
  missing_v1_ids = v1_ids - matched_ids.uniq
  puts "Missing v1_ids: #{missing_v1_ids.join(', ')}"
end

# Output results to CSV
CSV.open('lib/suivi_dtnum/v1_v2_ids_matcher/matched_ids.csv', 'w') do |csv|
  csv << ['datapass_v1_id', 'demande_v2_id', 'habilitation_v2_id']
  
  results.each do |row|
    csv << row
  end
end

puts "Results written to matched_ids.csv\n\n"