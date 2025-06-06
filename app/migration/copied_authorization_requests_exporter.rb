require 'csv'

class CopiedAuthorizationRequestsExporter
  def perform
    copy_chains = build_copy_chains
    generate_csv(copy_chains)
    puts "CSV exported to: sandbox/copied_authorization_requests.csv"
    puts "Found #{copy_chains.values.flatten.count} authorization requests with copied_from_request_id"
    puts "Grouped into #{copy_chains.count} copy chains"
  end

  private

  def sandbox_types
    @sandbox_types ||= AuthorizationDefinition.all.select { |d| d.stage.exists? && d.stage.type == 'sandbox' }.map { |d| d.authorization_request_class.to_s }
  end

  def build_copy_chains
    chains = {}
    processed_ids = Set.new

    # Find all requests with copied_from_request_id that are sandbox types
    AuthorizationRequest.where.not(copied_from_request_id: nil).where(type: sandbox_types).find_each do |request|
      next if processed_ids.include?(request.id)

      # Find the root of this chain (which might not be a sandbox type)
      root = find_chain_root(request)
      chain = build_chain_from_root(root)

      # Only keep chains that have at least one sandbox type request
      next if chain.empty?

      # Mark all requests in this chain as processed
      chain.each { |r| processed_ids.add(r.id) }

      # Store the chain
      chains[root.id] = chain
    end

    chains
  end

  def find_chain_root(request)
    current = request
    while current.copied_from_request_id.present?
      parent = AuthorizationRequest.find_by(id: current.copied_from_request_id)
      break unless parent
      current = parent
    end
    current
  end

  def build_chain_from_root(root)
    chain = [root]
    current = root
    has_sandbox = sandbox_types.include?(root.type)

    # Follow the chain forward and include all requests
    while true
      next_copy = AuthorizationRequest.find_by(copied_from_request_id: current.id)
      break unless next_copy
      chain << next_copy
      has_sandbox = true if sandbox_types.include?(next_copy.type)
      current = next_copy
    end

    # Only return the chain if it contains at least one sandbox type
    has_sandbox ? chain : []
  end

  def generate_csv(copy_chains)
    ensure_sandbox_directory_exists

    CSV.open('sandbox/copied_authorization_requests.csv', 'w') do |csv|
      csv << headers

      copy_chains.each_with_index do |(root_id, chain), group_index|
        csv << ["GROUP #{group_index + 1}", "Chain of #{chain.size} requests", "", "", "", "", "", "", ""]

        chain.each_with_index do |request, index|
          csv << row_for_request(request, index == 0)
        end

        csv << ["", "", "", "", "", "", "", "", ""] # Empty row between groups
      end

      # Summary at the end
      csv << ["SUMMARY", "", "", "", "", "", "", "", ""]
      csv << ["Total groups:", copy_chains.count, "", "", "", "", "", "", ""]
      csv << ["Total requests:", copy_chains.values.flatten.count, "", "", "", "", "", "", ""]
    end
  end

  def headers
    ['ID', 'Type', 'State', 'Copied From ID', 'V1 Link', 'V2 Link', 'Copied From V1 Link', 'Copied From V2 Link', 'Position in Chain']
  end

  def row_for_request(request, is_root)
    copied_from = request.copied_from_request_id ?
                  AuthorizationRequest.find_by(id: request.copied_from_request_id) :
                  nil

    [
      request.id,
      request.type,
      request.state,
      request.copied_from_request_id || (is_root ? 'ROOT' : ''),
      v1_link(request),
      v2_link(request),
      copied_from ? v1_link(copied_from) : '',
      copied_from ? v2_link(copied_from) : '',
      is_root ? 'ROOT' : 'COPY'
    ]
  end

  def v1_link(request)
    "https://v1.datapass.api.gouv.fr/#{request.form_uid}/#{request.id}"
  end

  def v2_link(request)
    "https://datapass.api.gouv.fr/demandes/#{request.id}"
  end

  def ensure_sandbox_directory_exists
    Dir.mkdir('sandbox') unless Dir.exist?('sandbox')
  end
end
