RSpec.describe 'POST /auth/proconnect' do
  subject(:authorization_uri) do
    post '/auth/proconnect'

    URI(response.location)
  end

  around do |example|
    OmniAuth.config.test_mode = false
    example.run
  ensure
    OmniAuth.config.test_mode = true
  end

  it 'redirects to the ProConnect authorization endpoint' do
    expect(authorization_uri.to_s).to start_with('https://test.proconnect.gouv.fr/authorize?')
  end

  it 'requires a MFA acr as an essential claim of the id_token' do
    claims = Rack::Utils.parse_query(authorization_uri.query)['claims']

    expect(JSON.parse(claims)).to eq(
      'id_token' => {
        'acr' => {
          'essential' => true,
          'values' => %w[eidas0-mfa eidas1-mfa eidas2 eidas3]
        }
      }
    )
  end
end
