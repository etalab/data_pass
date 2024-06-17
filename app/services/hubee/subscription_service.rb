class HubEE::SubscriptionService
  def initialize(api_host, access_token, id, authorization_request, etablissement_response, scope, administrateur_metier_data)
    @api_host = api_host
    @access_token = access_token
    @authorization_request = authorization_request
    @etablissement_response = etablissement_response
    @scope = scope
    @administrateur_metier_data = administrateur_metier_data
    @id = id
  end

  def create_subscriptions
    faraday_connection.post do |req|
      req.url "#{@api_host}/referential/v1/subscriptions"
      req.headers['Authorization'] = "Bearer #{@access_token}"
      req.headers['tag'] = 'Portail HubEE'
      req.body = subscription_body
    end['authorization_id']
  end

  private

  def subscription_body
    {
      datapassId: @id,
      processCode: @scope,
      subscriber: {
        type: 'SI',
        companyRegister: @authorization_request.organization[:siret],
        branchCode: @etablissement_response[:code_commune]
      },
      accessMode: nil,
      notificationFrequency: 'unitaire',
      activateDateTime: nil,
      validateDateTime: @authorization_request.last_validated_at.iso8601,
      rejectDateTime: nil,
      endDateTime: nil,
      updateDateTime: @authorization_request[:updated_at].iso8601,
      delegationActor: nil,
      rejectionReason: nil,
      status: 'Inactif',
      email: @administrateur_metier_data[:email],
      localAdministrator: {
        email: @administrateur_metier_data[:email],
        firstName: @administrateur_metier_data[:given_name],
        lastName: @administrateur_metier_data[:family_name],
        function: @administrateur_metier_data[:job_title],
        phoneNumber: @administrateur_metier_data[:phone_number].delete(' ').delete('.').delete('-'),
        mobileNumber: nil
      }
    }
  end

  def faraday_connection
    @faraday_connection ||= Faraday.new do |conn|
      conn.request :json
      conn.request :retry, max: 5
      conn.response :raise_error
      conn.response :json, content_type: /\bjson$/
      conn.options.timeout = 2
      conn.adapter Faraday.default_adapter
    end
  end
end
