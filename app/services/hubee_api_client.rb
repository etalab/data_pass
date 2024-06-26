class HubEEAPIClient
  def get_organization(organization)
    http_connection do |conn|
      conn.headers['Authorization'] = "Bearer #{access_token}"
    end.get("https://hubee.fr/referential/v1/organizations/SI-#{organization.siret}-#{organization.code_commune}").body
  end

  def create_subscription(authorization_request, hubee_organization, process_code)
    http_connection do |conn|
      conn.headers['Authorization'] = "Bearer #{access_token}"
      conn.request :json
    end.post(
      "https://hubee.fr/referential/v1/subscriptions",
    ) do |req|
      req.body = {
        'datapassId': authorization_request.id,
      }.to_json
    end
  end

  def access_token
    http_connection.post(
      hubee_auth_url,
      'grant_type=client_credentials&scope=ADMIN',
      {
        'Authorization' => "Basic #{encoded_client_id_and_secret}",
      },
    ).body['access_token']
  end

  private

  def hubee_auth_url
    'https://hubee.fr/oauth2/token'
  end

  def consumer_key
    'lol'
  end

  def consumer_secret
    'ok'
  end

  def encoded_client_id_and_secret
    Base64.strict_encode64("#{consumer_key}:#{consumer_secret}")
  end

  def http_connection(&block)
    @http_connection ||= Faraday.new do |conn|
      conn.request :retry, max: 5
      conn.response :raise_error
      conn.response :json
      conn.options.timeout = 2
      yield(conn) if block
    end
  end
end
