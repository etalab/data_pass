class MergeAuthorizationRequests
  attr_reader :from_id, :to_id, :auto

  def initialize(from_id, to_id, auto: false)
    @from_id = from_id
    @to_id = to_id
    @auto = auto
  end

  def perform
    return if redis_backend_handled.elements.include?(from_id.to_s)

    check_existence_of_requests!
    check_all_requests_validated!

    unless @auto
      answer = display_infos
      return unless answer.downcase == 'y' || answer.empty?
    end

    mark_from_authorizations_as_obsolete!
    run_sql

    redis_backend_handled << from_id.to_s

    displays_results
  end

  private

  def redis_backend_handled
    @redis_backend_handled ||= Kredis.list "merged_authorization_request_ids"
  end

  def display_infos
    print "from (#{@from_request.type} state: #{@from_request.state}):\n"
    print "> https://v1.datapass.api.gouv.fr/api-sfip-sandbox/#{from_id}\n"
    print "> https://datapass.api.gouv.fr/demandes/#{from_id}\n"
    print "\n"
    print "to (#{@from_request.type} state: #{@to_request.state}):\n"
    print "> https://v1.datapass.api.gouv.fr/api-sfip-sandbox/#{to_id}\n"
    print "> https://datapass.api.gouv.fr/demandes/#{to_id}\n"
    print "\n"
    if @to_request.copied_from_request_id != @from_request.id
      print "WARNING: The request to merge into (#{to_id}) was not copied from the request to merge from (#{from_id}).\n"
    else
      print "The request to merge into (#{to_id}) was copied from the request to merge from (#{from_id}).\n"
    end

    print "Continue? (Y/n)\n"
    STDIN.gets.chomp
  end

  def displays_results
    print "DONE\n"

    unless Rails.env.production?
      print "> http://localhost:3000/demandes/#{to_id}\n"
      print "> http://localhost:5000/demandes/#{to_id}\n"
    end

    print "> https://datapass.api.gouv.fr/demandes/#{to_id}\n"

    next_copy = AuthorizationRequest.find_by(copied_from_request_id: @to_request.id)

    if next_copy
      print "Next copy exists\n"
      print "> https://v1.datapass.api.gouv.fr/api-sfip-sandbox/#{next_copy.id}\n"
      print "> https://datapass.api.gouv.fr/demandes/#{next_copy.id}\n"
      print "> Authorizations ids: #{next_copy.authorizations.pluck(:id).join(', ')}\n"
      print "Run: MergeAuthorizationRequests.new(#{to_id}, #{next_copy.id}).perform\n"

      if @auto
        MergeAuthorizationRequests.new(to_id, next_copy.id, auto: true).perform
      else
        print "Do you want to merge the next copy? (Y/n)\n"
        answer = gets.chomp

        if answer.downcase == 'y' || answer.empty?
          MergeAuthorizationRequests.new(to_id, next_copy.id).perform
        else
          print "Skipping next copy merge.\n"
        end
      end
    end
  end

  def check_existence_of_requests!
    @from_request = AuthorizationRequest.find_by(id: from_id) || Authorization.find_by(id: from_id)&.request
    @to_request = AuthorizationRequest.find_by(id: to_id) || Authorization.find_by(id: to_id)&.request
    print "Run ./app/migration/local_run.sh to populate the database\n" if !Rails.env.production? && (@from_request.nil? || @to_request.nil?)

    raise ActiveRecord::RecordNotFound, "Authorization request with id #{from_id} does not exist." unless @from_request
    raise ActiveRecord::RecordNotFound, "Authorization request with id #{to_id} does not exist." unless @to_request

    @from_id = @from_request&.id
    @to_id = @to_request&.id

    if @from_request == @to_request
      raise ArgumentError, "Cannot merge the same authorization request (id: #{from_id}) into itself."
    end
  end

  def check_all_requests_validated!
    copy_chain = build_copy_chain
    non_validated_requests = copy_chain.reject { |request| request.state == 'validated' }

    if non_validated_requests.any?
      non_validated_states = non_validated_requests.map { |r| "#{r.id}:#{r.state}" }.join(', ')
      raise ArgumentError, "Cannot merge authorization requests that are not validated. Non-validated requests found: #{non_validated_states}"
    end
  end

  def build_copy_chain
    chain = [@from_request, @to_request]

    # Find all requests in the copy chain by following copied_from_request_id relationships
    current = @to_request
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

  def run_sql
    sql = <<-SQL
    BEGIN;

    UPDATE messages
    SET authorization_request_id = #{to_id}
    WHERE authorization_request_id = #{from_id};

    UPDATE authorization_request_changelogs
    SET authorization_request_id = #{to_id}
    WHERE authorization_request_id = #{from_id};

    UPDATE instructor_modification_requests
    SET authorization_request_id = #{to_id}
    WHERE authorization_request_id = #{from_id};

    UPDATE denial_of_authorizations
    SET authorization_request_id = #{to_id}
    WHERE authorization_request_id = #{from_id};

    UPDATE revocation_of_authorizations
    SET authorization_request_id = #{to_id}
    WHERE authorization_request_id = #{from_id};

    UPDATE authorization_request_transfers
    SET authorization_request_id = #{to_id}
    WHERE authorization_request_id = #{from_id};

    UPDATE authorizations
    SET request_id = #{to_id}
    WHERE request_id = #{from_id};

    UPDATE active_storage_attachments
    SET record_id = #{to_id}
    WHERE record_type = 'AuthorizationRequest' AND record_id = #{from_id};

    UPDATE authorization_request_events
    SET authorization_request_id = #{to_id}
    WHERE authorization_request_id = #{from_id};

    -- Supprimer l'ancien enregistrement
    DELETE FROM authorization_requests
    WHERE id = #{from_id};

    COMMIT;
    SQL

    ActiveRecord::Base.connection.execute(sql)
  end

  def mark_from_authorizations_as_obsolete!
    Authorization.where(request_id: from_id).find_each do |authorization|
      authorization.deprecate
    end
  end
end
