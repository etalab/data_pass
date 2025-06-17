require 'csv'
require 'sqlite3'

class V1CopiedEnrollmentsExporter
  include LocalDatabaseUtils

  def perform
    copy_chains = build_copy_chains
    copy_chains = clean_copy_chains_already_merged(copy_chains)
    generate_csv(copy_chains)
    generate_ids_file(copy_chains)
    Rails.logger.debug 'CSV exported to: sandbox/v1_copied_enrollments.csv'
    Rails.logger.debug 'IDs file exported to: sandbox/validated_copy_ids.rb'
    Rails.logger.debug { "Found #{copy_chains.values.flatten.count} enrollments with copied_from_enrollment_id or previous_enrollment_id" }
    Rails.logger.debug { "Grouped into #{copy_chains.count} copy chains" }
  end

  private

  def build_copy_chains
    chains = {}
    processed_ids = Set.new

    # Query enrollments with copied_from_enrollment_id only (exclude previous_enrollment_id chains)
    # Only include target_api matching %_sandbox, %_production or %_unique
    query = <<-SQL.squish
      SELECT DISTINCT e1.*
      FROM enrollments e1
      WHERE e1.copied_from_enrollment_id IS NOT NULL#{' '}
      AND (e1.target_api LIKE '%_sandbox'#{' '}
           OR e1.target_api LIKE '%_production'#{' '}
           OR e1.target_api LIKE '%_unique')
    SQL

    database.execute(query).each do |row|
      enrollment = parse_enrollment(row)
      next if processed_ids.include?(enrollment[:id])

      # Build the complete copy chain using the enhanced logic from MergeAuthorizationRequests
      chain = build_complete_copy_chain(enrollment)

      # Mark all enrollments in this chain as processed
      chain.each { |e| processed_ids.add(e[:id]) }

      # Store the chain using the root as key
      root = chain.first
      chains[root[:id]] = chain
    end

    chains
  end

  def clean_copy_chains_already_merged(copy_chains)
    copy_chains.reject do |_root_id, chain|
      from_id = chain.first[:id]
      to_id = chain.second[:id]

      from = AuthorizationRequest.find_by(id: from_id) || Authorization.find_by(id: from_id)&.request
      to = AuthorizationRequest.find_by(id: to_id) || Authorization.find_by(id: to_id)&.request

      from == to
    end
  end

  def find_chain_root(enrollment)
    current = enrollment
    visited = Set.new

    while current[:copied_from_enrollment_id]
      # Cycle detection
      if visited.include?(current[:id])
        Rails.logger.debug { "Warning: Cycle detected at enrollment #{current[:id]}, stopping traversal" }
        break
      end
      visited.add(current[:id])

      parent_id = current[:copied_from_enrollment_id]
      parent = fetch_enrollment(parent_id)
      break unless parent

      current = parent
    end

    current
  end

  def build_complete_copy_chain(enrollment)
    chain = [enrollment]

    # Step 1: Find all V1 enrollments in the copy chain by following copied_from_enrollment_id relationships
    current = enrollment
    while current && current[:copied_from_enrollment_id] && current[:copied_from_enrollment_id] != current[:id]
      parent = fetch_enrollment(current[:copied_from_enrollment_id])
      break unless parent
      break if chain.any? { |e| e[:id] == parent[:id] } # Prevent infinite loops

      chain.unshift(parent) unless chain.any? { |e| e[:id] == parent[:id] }
      current = parent
    end

    # Step 2: Also check for any V1 enrollments that copy from the current chain
    chain_ids = chain.map { |e| e[:id] }
    additional_v1_copies = find_additional_v1_copies(chain_ids)
    additional_v1_copies.each do |copy|
      chain << copy unless chain.any? { |e| e[:id] == copy[:id] }
    end

    # Step 3: For each enrollment in the chain, check if it has been migrated to V2
    # and include the whole V2 copy chain
    v2_chain_additions = []
    chain.each do |v1_enrollment|
      v2_request = find_v2_authorization_request(v1_enrollment[:id])
      next unless v2_request

      v2_copy_chain = build_v2_copy_chain(v2_request)
      v2_copy_chain.each do |v2_req|
        # Convert V2 request to enrollment-like structure for consistency
        v2_enrollment = convert_v2_to_enrollment_structure(v2_req)
        v2_chain_additions << v2_enrollment unless chain.any? { |e| e[:id] == v2_enrollment[:id] } || v2_chain_additions.any? { |e| e[:id] == v2_enrollment[:id] }
      end
    end

    # Add V2 chain additions to the main chain
    chain.concat(v2_chain_additions)

    # Remove duplicates based on ID and return sorted by ID for consistency
    chain.uniq { |e| e[:id] }.sort_by { |e| e[:id] }
  end

  def build_chain_from_root(root)
    chain = [root]
    current = root
    visited = Set.new([root[:id]])

    # Follow the chain forward
    loop do
      # Find enrollments that have current as their copied_from or previous
      next_copies = find_next_copies(current[:id])
      break if next_copies.empty?

      # Filter out already visited enrollments to prevent cycles
      next_copies = next_copies.reject { |copy| visited.include?(copy[:id]) }
      break if next_copies.empty?

      # For simplicity, follow the first branch (could be enhanced to handle multiple branches)
      next_copy = next_copies.first

      # Cycle detection
      if visited.include?(next_copy[:id])
        Rails.logger.debug { "Warning: Cycle detected at enrollment #{next_copy[:id]}, stopping chain building" }
        break
      end

      chain << next_copy
      visited.add(next_copy[:id])
      current = next_copy
    end

    chain
  end

  def find_next_copies(enrollment_id)
    query = <<-SQL.squish
      SELECT * FROM enrollments#{' '}
      WHERE copied_from_enrollment_id = ?#{' '}
      AND (target_api LIKE '%_sandbox'#{' '}
           OR target_api LIKE '%_production'#{' '}
           OR target_api LIKE '%_unique')
    SQL

    database.execute(query, [enrollment_id]).map { |row| parse_enrollment(row) }
  end

  def fetch_enrollment(enrollment_id)
    query = <<-SQL.squish
      SELECT * FROM enrollments#{' '}
      WHERE id = ?#{' '}
      AND (target_api LIKE '%_sandbox'#{' '}
           OR target_api LIKE '%_production'#{' '}
           OR target_api LIKE '%_unique')
    SQL
    result = database.execute(query, [enrollment_id]).first
    result ? parse_enrollment(result) : nil
  end

  def parse_enrollment(row)
    {
      id: row[0],
      target_api: row[1],
      status: row[2],
      user_id: row[3],
      copied_from_enrollment_id: row[4],
      previous_enrollment_id: row[5],
      raw_data: row[6]
    }
  end

  def find_additional_v1_copies(chain_ids)
    return [] if chain_ids.empty?

    placeholders = (['?'] * chain_ids.size).join(',')
    query = <<-SQL.squish
      SELECT * FROM enrollments
      WHERE copied_from_enrollment_id IN (#{placeholders})
      AND (target_api LIKE '%_sandbox'
           OR target_api LIKE '%_production'
           OR target_api LIKE '%_unique')
    SQL

    database.execute(query, chain_ids).map { |row| parse_enrollment(row) }
  end

  def find_v2_authorization_request(v1_enrollment_id)
    AuthorizationRequest.find_by(id: v1_enrollment_id) || Authorization.find_by(id: v1_enrollment_id)&.request
  end

  def build_v2_copy_chain(v2_request)
    chain = [v2_request]

    # Find all requests in the copy chain by following copied_from_request_id relationships
    current = v2_request
    while current&.copied_from_request_id && current.copied_from_request_id != current.id
      parent = AuthorizationRequest.find_by(id: current.copied_from_request_id) || Authorization.find_by(id: current.copied_from_request_id)&.request
      break unless parent
      break if chain.include?(parent) # Prevent infinite loops

      chain.unshift(parent) unless chain.include?(parent)
      current = parent
    end

    # Also check for any requests that copy from the current chain
    chain_ids = chain.map(&:id)
    additional_copies = AuthorizationRequest.where(copied_from_request_id: chain_ids).to_a
    additional_copies.each do |copy|
      chain << copy unless chain.include?(copy)
    end

    chain.uniq
  end

  def convert_v2_to_enrollment_structure(v2_request)
    {
      id: v2_request.id,
      target_api: v2_request.definition.id,
      status: v2_request.state,
      user_id: v2_request.applicant_id,
      copied_from_enrollment_id: v2_request.copied_from_request_id,
      previous_enrollment_id: nil,
      raw_data: nil,
      v2_request: true
    }
  end

  def generate_csv(copy_chains)
    ensure_sandbox_directory_exists

    CSV.open('sandbox/v1_copied_enrollments.csv', 'w') do |csv|
      csv << headers

      copy_chains.each_with_index do |(_root_id, chain), group_index|
        csv << ["GROUP #{group_index + 1}", "Chain of #{chain.size} enrollments", '', '', '', '', '', '', '', '', '']

        chain.each_with_index do |enrollment, index|
          csv << row_for_enrollment(enrollment, index.zero?)
        end

        csv << ['', '', '', '', '', '', '', '', '', '', ''] # Empty row between groups
      end

      # Summary at the end
      csv << ['SUMMARY', '', '', '', '', '', '', '', '', '', '']
      csv << ['Total groups:', copy_chains.count, '', '', '', '', '', '', '', '', '']
      csv << ['Total enrollments:', copy_chains.values.flatten.count, '', '', '', '', '', '', '', '', '']
    end
  end

  def headers
    ['ID', 'Target API', 'Status', 'Copied From ID', 'Previous ID', 'V1 Link', 'V2 Redirect Link', 'Copied/Previous V1 Link', 'Copied/Previous V2 Link', 'Position in Chain', 'Type']
  end

  def row_for_enrollment(enrollment, is_root)
    copied_or_previous_id = enrollment[:copied_from_enrollment_id] || enrollment[:previous_enrollment_id]

    # Handle both V1 and V2 requests when looking up copied/previous
    if enrollment[:v2_request]
      copied_or_previous = copied_or_previous_id ? find_v2_authorization_request(copied_or_previous_id) : nil
      copied_or_previous = convert_v2_to_enrollment_structure(copied_or_previous) if copied_or_previous
    else
      copied_or_previous = copied_or_previous_id ? fetch_enrollment(copied_or_previous_id) : nil
    end

    [
      enrollment[:id],
      enrollment[:target_api],
      enrollment[:status],
      enrollment[:copied_from_enrollment_id] || '',
      enrollment[:previous_enrollment_id] || '',
      v1_link(enrollment),
      enrollment[:v2_request] ? v2_direct_link(enrollment) : v2_redirect_link(enrollment),
      copied_or_previous ? v1_link(copied_or_previous) : '',
      if copied_or_previous
        copied_or_previous[:v2_request] ? v2_direct_link(copied_or_previous) : v2_redirect_link(copied_or_previous)
      else
        ''
      end,
      is_root ? 'ROOT' : 'COPY',
      enrollment[:v2_request] ? 'V2' : 'V1'
    ]
  end

  def v1_link(enrollment)
    "https://v1.datapass.api.gouv.fr/#{enrollment[:target_api]}/#{enrollment[:id]}"
  end

  def v2_redirect_link(enrollment)
    "https://datapass.api.gouv.fr/redirect-from-v1/#{enrollment[:id]}"
  end

  def v2_direct_link(enrollment)
    "https://datapass.api.gouv.fr/demandes/#{enrollment[:id]}"
  end

  def generate_ids_file(copy_chains)
    ensure_sandbox_directory_exists

    copy_ids = {}
    v1_to_v2_mappings = {}

    copy_chains.each do |root_id, chain|
      # Original logic for V1 copy chains
      copied_enrollment = chain.find { |enrollment| enrollment[:copied_from_enrollment_id] && !enrollment[:v2_request] }
      copy_ids[root_id] = copied_enrollment[:id] if copied_enrollment

      # New logic for V1 to V2 mappings
      v1_enrollments = chain.reject { |enrollment| enrollment[:v2_request] }
      v2_enrollments = chain.select { |enrollment| enrollment[:v2_request] }

      v1_enrollments.each do |v1_enrollment|
        v2_equivalent = v2_enrollments.find { |v2_enrollment| v2_enrollment[:id] == v1_enrollment[:id] }
        v1_to_v2_mappings[v1_enrollment[:id]] = v2_equivalent[:id] if v2_equivalent
      end
    end

    File.open('sandbox/validated_copy_ids.rb', 'w') do |file|
      file.puts 'def v1_copy_ids'
      file.puts '  {'
      copy_ids.each do |from_id, to_id|
        file.puts "    #{from_id} => #{to_id},"
      end
      file.puts '  }'
      file.puts 'end'
      file.puts ''
      file.puts 'def v1_to_v2_mappings'
      file.puts '  {'
      v1_to_v2_mappings.each do |v1_id, v2_id|
        file.puts "    #{v1_id} => #{v2_id},"
      end
      file.puts '  }'
      file.puts 'end'
      file.puts ''
      file.puts 'def ids'
      file.puts '  {'
      copy_ids.each do |from_id, to_id|
        file.puts "    #{from_id} => #{to_id},"
      end
      file.puts '  }'
      file.puts 'end'
    end
  end

  def all_enrollments_validated?(chain)
    chain.all? { |enrollment| enrollment[:status] == 'validated' }
  end

  def ensure_sandbox_directory_exists
    FileUtils.mkdir_p('sandbox')
  end
end
