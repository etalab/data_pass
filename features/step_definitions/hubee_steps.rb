def stub_hubee_json(method, url, status:, body:)
  stub_request(method, url)
    .to_return(status:, body: body.to_json, headers: { 'Content-Type' => 'application/json' })
end

Sachantque('l’API HubEE accepte les abonnements') do
  hubee_host = Rails.application.credentials.hubee_host

  stub_hubee_json(:post, Rails.application.credentials.hubee_auth_url, status: 200, body: { 'access_token' => 'hubee_access_token' })
  stub_hubee_json(:get, %r{\A#{Regexp.escape(hubee_host)}/referential/v1/organizations/}, status: 200, body: FactoryBot.build(:hubee_organization_payload))
  stub_hubee_json(:post, "#{hubee_host}/referential/v1/subscriptions", status: 201, body: FactoryBot.build(:hubee_subscription_response_payload))
end
