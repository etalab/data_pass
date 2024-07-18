class HubEEAPIClient
  class AlreadyExistsError < StandardError; end

  def get_organization(siret, code_commune)
    faraday_connection.get { |req|
      req.url "#{api_host}/referential/v1/organizations/SI-#{siret}-#{code_commune}"
      req.headers['Authorization'] = "Bearer #{access_token}"
      req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
    }.body.with_indifferent_access
  end

  # rubocop:disable Metrics/AbcSize
  def create_organization(organization_payload)
    faraday_connection.post { |req|
      req.url "#{api_host}/referential/v1/organizations"
      req.headers['Authorization'] = "Bearer #{access_token}"
      req.headers['Content-Type'] = 'application/json'
      req.headers['tag'] = 'Portail HubEE'
      req.body = organization_payload.to_json
    }.body.with_indifferent_access
  rescue Faraday::BadRequestError => e
    raise AlreadyExistsError if e.response[:body]['errors'][0]['message'].include?('already exists')

    raise
  end

  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize
  def create_subscription(subscription_body)
    faraday_connection.post { |req|
      req.headers['Authorization'] = "Bearer #{access_token}"
      req.headers['Content-Type'] = 'application/json'
      req.url "#{api_host}/referential/v1/subscriptions"
      req.body = subscription_body.to_json
    }.body.with_indifferent_access
  rescue Faraday::BadRequestError => e
    raise AlreadyExistsError if e.response[:body]['errors'][0]['message'].include?('already exists')

    raise
  end

  # rubocop:enable Metrics/AbcSize

  private

  def access_token
    response = faraday_connection.post do |req|
      req.url hubee_auth_url
      req.headers['Authorization'] = "Basic #{encoded_client_id_and_secret}"
      req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
      req.headers['tag'] = 'Portail HubEE'
      req.body = URI.encode_www_form({ grant_type: 'client_credentials', scope: 'ADMIN' })
    end

    response.body['access_token']
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

  def faraday_connection
    @faraday_connection ||= Faraday.new do |conn|
      conn.request :retry, max: 5
      conn.response :raise_error
      conn.response :json, content_type: /\bjson$/
      conn.request :json
      conn.options.timeout = 2
      conn.adapter Faraday.default_adapter
    end
  end
end
