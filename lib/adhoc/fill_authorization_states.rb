class FillAuthorizationStates < BaseInteractor
  class LatestAuthorizationForRequest
    attr_reader :authorizations

    def initialize(auth_requests)
      @authorizations = scope_for(auth_requests).group_by(&:request_id)
    end

    def for_request(auth_request)
      @authorization[auth_request.id] || []
    end

    private

    def scope_for(auth_requests)
      ranked_auths = Authorization.where(request_id: auth_requests).select(<<-SQL)
        authorizations.*,
        dense_rank() OVER (
          PARTITION BY authorizations.request_id
          ORDER BY authorizations.id DESC
        ) AS authorization_rank
      SQL

      Authorization.from(ranked_auths, "authorizations").where("authorization_rank <= 1").where.not(state: :revoked)
    end
  end  

  latest_auths = LatestAuthorizationForRequest.new(AuthorizationRequest.all)
  latest_auths.authorizations.each do |request_id, auths|
    puts "#{request_id} -> #{auths.first.form_uid}"
  end

  def call
    Authorization.where(revoked: true).update_all(state: :revoked)
    Authorization.where(revoked: false).update_all(state: :inactive)

  end
end
