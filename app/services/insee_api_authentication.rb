# frozen_string_literal: true

class INSEEAPIAuthentication < AbstractINSEEAPIClient
  def access_token
    ensure_insee_available!

    http_connection.post(
      'https://auth.insee.net/auth/realms/apim-gravitee/protocol/openid-connect/token',
      {
        'grant_type' => 'password',
        'client_id' => client_id,
        'client_secret' => client_secret,
        'username' => username,
        'password' => password,
      }.to_query,
    ).body['access_token']
  rescue Faraday::BadRequestError, Faraday::UnauthorizedError => e
    pause_insee_calls!(e, 'INSEE rejected our credentials')
  end

  protected

  def http_connection
    super do |conn|
      conn.request :retry, retry_options
      conn.headers['Content-Type'] = 'application/x-www-form-urlencoded'
    end
  end

  def retry_options
    {
      max: 5,
      interval: 0.05,
      interval_randomness: 0.5,
      backoff_factor: 2,
      exceptions: [
        Faraday::ConnectionFailed,
        Faraday::TimeoutError,
        Faraday::ParsingError,
        Faraday::ClientError,
        Faraday::ServerError,
        Faraday::UnauthorizedError,
      ],
    }
  end

  private

  def client_id
    Setting.fetch(:insee_client_id)
  end

  def client_secret
    Setting.fetch(:insee_client_secret)
  end

  def username
    Setting.fetch(:insee_username)
  end

  def password
    Setting.fetch(:insee_password)
  end
end
