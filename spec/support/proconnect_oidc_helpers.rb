module ProConnectOidcHelpers
  PROCONNECT_TEST_HOST = 'https://test.proconnect.gouv.fr'.freeze
  PROCONNECT_TEST_ISSUER = "#{PROCONNECT_TEST_HOST}/api/v2".freeze

  def proconnect_signing_key
    @proconnect_signing_key ||= OpenSSL::PKey::RSA.generate(2048).to_jwk
  end

  def proconnect_signed_id_token(claims, key: proconnect_signing_key, client_id: ProConnectConfig.client_id, algorithm: :RS256)
    jwt = JSON::JWT.new(
      {
        iss: PROCONNECT_TEST_ISSUER,
        aud: client_id,
        exp: 5.minutes.from_now.to_i,
        iat: Time.now.to_i
      }.merge(claims)
    )
    jwt.kid = key[:kid] if key.is_a?(JSON::JWK)
    jwt.sign(key, algorithm).to_s
  end

  def stub_proconnect_oidc_endpoints(id_token:, userinfo:)
    stub_proconnect_discovery
    stub_proconnect_json(:get, '/jwks', { keys: [proconnect_signing_key.normalize.merge(kid: proconnect_signing_key[:kid])] })
    stub_proconnect_json(:post, '/token', { access_token: 'access-token', id_token: })
    stub_request(:get, "#{PROCONNECT_TEST_HOST}/userinfo").to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/jwt' },
      body: userinfo
    )
  end

  def stub_proconnect_discovery
    stub_proconnect_json(:get, %r{.well-known/openid-configuration$}, {
      issuer: PROCONNECT_TEST_ISSUER,
      authorization_endpoint: "#{PROCONNECT_TEST_HOST}/authorize",
      token_endpoint: "#{PROCONNECT_TEST_HOST}/token",
      userinfo_endpoint: "#{PROCONNECT_TEST_HOST}/userinfo",
      end_session_endpoint: "#{PROCONNECT_TEST_HOST}/session/end",
      jwks_uri: "#{PROCONNECT_TEST_HOST}/jwks"
    })
  end

  def stub_proconnect_json(method, path, body)
    url = path.is_a?(Regexp) ? path : "#{PROCONNECT_TEST_HOST}#{path}"

    stub_request(method, url).to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: body.to_json
    )
  end

  def proconnect_authorization_params(path, params = {})
    post(path, params:)

    Rack::Utils.parse_query(URI(response.location).query)
  end
end

RSpec.configure do |config|
  config.include ProConnectOidcHelpers, type: :request
end
