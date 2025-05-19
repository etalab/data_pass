# frozen_string_literal: true

class INSEEAPIAuthentication < AbstractINSEEAPIClient
  def access_token
    Retriable.retriable(on: Faraday::UnauthorizedError, tries: 5) do
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
  end

  private

  def client_id
    Rails.application.credentials.insee_client_id
  end

  def client_secret
    Rails.application.credentials.insee_client_secret
  end

  def username
    Rails.application.credentials.insee_username
  end

  def password
    Rails.application.credentials.insee_password
  end
end
