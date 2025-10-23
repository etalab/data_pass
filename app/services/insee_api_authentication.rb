# frozen_string_literal: true

class INSEEAPIAuthentication < AbstractINSEEAPIClient
  def access_token
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
  end

  protected

  def http_connection
    super do |conn|
      conn.request :retry, retry_options
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
    ENV.fetch('INSEE_CLIENT_ID', Rails.application.credentials.insee_client_id)
  end

  def client_secret
    ENV.fetch('INSEE_CLIENT_SECRET', Rails.application.credentials.insee_client_secret)
  end

  def username
    ENV.fetch('INSEE_USERNAME', Rails.application.credentials.insee_username)
  end

  def password
    ENV.fetch('INSEE_PASSWORD', Rails.application.credentials.insee_password)
  end
end
