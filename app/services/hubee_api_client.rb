class HubEEAPIClient
  class AlreadyExistsError < StandardError; end

  def get_organization(siret, code_commune)
    get("referential/v1/organizations/SI-#{siret}-#{code_commune}")
  end

  def create_organization(organization_payload)
    post('referential/v1/organizations', organization_payload.to_json)
  end

  def create_subscription(subscription_body)
    post('referential/v1/subscriptions', subscription_body.to_json)
  end

  private

  def access_token
    return @access_token if @access_token.present?

    response = faraday_connection(with_token: false).post do |req|
      req.url hubee_auth_url
      req.headers['Authorization'] = "Basic #{encoded_client_id_and_secret}"
      req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
      req.body = URI.encode_www_form({ grant_type: 'client_credentials', scope: 'ADMIN' })
    end

    @access_token = response.body['access_token']
  end

  def get(path)
    request(:get, path, headers: { 'Content-Type' => 'application/x-www-form-urlencoded' })
  end

  def post(path, body)
    request(:post, path, body:, headers: { 'Content-Type' => 'application/json' })
  rescue Faraday::BadRequestError => e
    raise AlreadyExistsError if e.response[:body]['errors'][0]['message'].include?('already exists')

    raise e
  end

  def request(action, path, body: nil, headers: {})
    response = faraday_connection.send(action) do |req|
      req.url "#{api_host}/#{path}"
      req.headers.merge(headers) if headers.present?
      req.body = body if body.present?
    end

    response.body.with_indifferent_access
  end

  def faraday_connection(with_token: true)
    @faraday_connection ||= Faraday.new do |conn|
      conn.request :retry, max: 5
      conn.response :raise_error
      conn.response :json, content_type: /\bjson$/
      conn.request :json
      conn.options.timeout = 2
      conn.adapter Faraday.default_adapter
      conn.request(:authorization, :Bearer, access_token) if with_token
    end
  end

  def hubee_auth_url
    Rails.application.credentials.hubee_auth_url
  end

  def api_host
    Rails.application.credentials.hubee_host
  end

  def consumer_key
    Rails.application.credentials.hubee_consumer_key
  end

  def consumer_secret
    Rails.application.credentials.hubee_consumer_secret
  end

  def encoded_client_id_and_secret
    Base64.strict_encode64("#{consumer_key}:#{consumer_secret}")
  end
end
