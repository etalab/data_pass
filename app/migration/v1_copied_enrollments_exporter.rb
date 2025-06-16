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

      # Find the root of this chain
      root = find_chain_root(enrollment)
      chain = build_chain_from_root(root)

      # Mark all enrollments in this chain as processed
      chain.each { |e| processed_ids.add(e[:id]) }

      # Store the chain
      chains[root[:id]] = chain
    end

    chains
  end

  def clean_copy_chains_already_merged(copy_chains)
    copy_chains.reject do |root_id, chain|
      from_id, to_id = chain.first[:id], chain.second[:id]

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

  def generate_csv(copy_chains)
    ensure_sandbox_directory_exists

    CSV.open('sandbox/v1_copied_enrollments.csv', 'w') do |csv|
      csv << headers

      copy_chains.each_with_index do |(_root_id, chain), group_index|
        csv << ["GROUP #{group_index + 1}", "Chain of #{chain.size} enrollments", '', '', '', '', '', '', '', '']

        chain.each_with_index do |enrollment, index|
          csv << row_for_enrollment(enrollment, index.zero?)
        end

        csv << ['', '', '', '', '', '', '', '', '', ''] # Empty row between groups
      end

      # Summary at the end
      csv << ['SUMMARY', '', '', '', '', '', '', '', '', '']
      csv << ['Total groups:', copy_chains.count, '', '', '', '', '', '', '', '']
      csv << ['Total enrollments:', copy_chains.values.flatten.count, '', '', '', '', '', '', '', '']
    end
  end

  def headers
    ['ID', 'Target API', 'Status', 'Copied From ID', 'Previous ID', 'V1 Link', 'V2 Redirect Link', 'Copied/Previous V1 Link', 'Copied/Previous V2 Link', 'Position in Chain']
  end

  def row_for_enrollment(enrollment, is_root)
    copied_or_previous_id = enrollment[:copied_from_enrollment_id] || enrollment[:previous_enrollment_id]
    copied_or_previous = copied_or_previous_id ? fetch_enrollment(copied_or_previous_id) : nil

    [
      enrollment[:id],
      enrollment[:target_api],
      enrollment[:status],
      enrollment[:copied_from_enrollment_id] || '',
      enrollment[:previous_enrollment_id] || '',
      v1_link(enrollment),
      v2_redirect_link(enrollment),
      copied_or_previous ? v1_link(copied_or_previous) : '',
      copied_or_previous ? v2_redirect_link(copied_or_previous) : '',
      is_root ? 'ROOT' : 'COPY'
    ]
  end

  def v1_link(enrollment)
    "https://v1.datapass.api.gouv.fr/#{enrollment[:target_api]}/#{enrollment[:id]}"
  end

  def v2_redirect_link(enrollment)
    "https://datapass.api.gouv.fr/redirect-from-v1/#{enrollment[:id]}"
  end

  def generate_ids_file(copy_chains)
    ensure_sandbox_directory_exists

    copy_ids = {}

    copy_chains.each do |root_id, chain|
      copied_enrollment = chain.find { |enrollment| enrollment[:copied_from_enrollment_id] }
      copy_ids[root_id] = copied_enrollment[:id] if copied_enrollment
    end

    File.open('sandbox/validated_copy_ids.rb', 'w') do |file|
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
    chain.all? { |enrollment| 'validated' == enrollment[:status] }
  end

  def ensure_sandbox_directory_exists
    FileUtils.mkdir_p('sandbox')
  end
end
