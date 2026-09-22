# frozen_string_literal: true

class INSEEAPIAuthentication < AbstractINSEEAPIClient
  TOKEN_URL = 'https://auth.insee.net/auth/realms/apim-gravitee/protocol/openid-connect/token'

  TOKEN_EXPIRY_MARGIN = 1.minute
  MINIMUM_TOKEN_LIFETIME = 1.minute
  FALLBACK_TOKEN_LIFETIME = 5.minutes

  CachedAccessToken = Struct.new(:value, :expires_at) do
    def usable?
      value.present? && expires_at.future?
    end
  end

  class << self
    def access_token
      usable_access_token || renewed_access_token
    end

    def invalidate_access_token!
      @cached_access_token = nil
    end

    private

    def usable_access_token
      cached_access_token = @cached_access_token
      return unless cached_access_token&.usable?

      cached_access_token.value
    end

    def renewed_access_token
      payload = new.request_access_token
      @cached_access_token = CachedAccessToken.new(payload['access_token'], token_lifetime(payload).from_now)

      @cached_access_token.value
    end

    def token_lifetime(payload)
      announced_lifetime = payload['expires_in'].to_i
      return FALLBACK_TOKEN_LIFETIME if announced_lifetime.zero?

      [announced_lifetime.seconds - TOKEN_EXPIRY_MARGIN, MINIMUM_TOKEN_LIFETIME].max
    end
  end

  def request_access_token
    ensure_insee_available!

    validated_access_token_payload(http_connection.post(TOKEN_URL, credentials.to_query).body)
  rescue Faraday::BadRequestError, Faraday::UnauthorizedError => e
    pause_insee_calls!(e, 'INSEE rejected our credentials')
  end

  protected

  def http_connection
    super do |conn|
      conn.response :json
      conn.headers['Content-Type'] = 'application/x-www-form-urlencoded'
    end
  end

  private

  def validated_access_token_payload(payload)
    raise InvalidResponseError, 'INSEE token response is not a JSON object' unless payload.is_a?(Hash)
    raise InvalidResponseError, 'INSEE token response carries no access_token' if payload['access_token'].blank?

    payload
  end

  def credentials
    {
      'grant_type' => 'password',
      'client_id' => client_id,
      'client_secret' => client_secret,
      'username' => username,
      'password' => password,
    }
  end

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
