require 'webmock/cucumber'

WebMock.disable_net_connect!(allow_localhost: true, allow: 'http://chrome:3333')

Before do
  stub_request(:get, %r{.well-known/openid-configuration$}).to_return(
    status: 200,
    body: { authorization_endpoint: 'https://test.proconnect.gouv.fr/authorize' }.to_json,
    headers: { 'Content-Type' => 'application/json' }
  )

  OmniAuth::Strategies::Proconnect.instance_variable_set(:@discovered_configuration, nil)
  OmniAuth::Strategies::Proconnect.instance_variable_set(:@authorization_endpoint, nil)
end
