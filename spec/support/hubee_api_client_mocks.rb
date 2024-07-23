# frozen_string_literal: true

module HubEEAPIClientMocks
  def stub_hubee_create_subscription_error(factory_trait)
    stub_hubee_api_error('referential/v1/subscriptions', factory_trait)
  end

  def stub_hubee_create_subscription(payload)
    response_body = FactoryBot.build(:hubee_subscription_response_payload).merge(payload)

    stub_hubee_api(
      action: :post,
      path: 'referential/v1/subscriptions',
      body: payload,
      return_code: 201,
      return_body: response_body
    )
  end

  def stub_hubee_create_organization_error(factory_trait)
    stub_hubee_api_error('referential/v1/organizations', factory_trait)
  end

  def stub_hubee_create_organization(payload)
    stub_hubee_api(
      action: :post,
      path: 'referential/v1/organizations',
      body: payload,
      return_body: payload
    )
  end

  def stub_hubee_get_organization_error(siret, code_commune)
    stub_hubee_api(
      action: :get,
      path: "referential/v1/organizations/SI-#{siret}-#{code_commune}",
      return_code: 404
    )
  end

  def stub_hubee_get_organization(siret, code_commune, payload)
    stub_hubee_api(
      action: :get,
      path: "referential/v1/organizations/SI-#{siret}-#{code_commune}",
      return_body: payload
    )
  end

  def stub_hubee_auth
    stub_request(:post, Rails.application.credentials.hubee_auth_url)
      .to_return(status: 200, body: { 'access_token' => 'some_access_token' }.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  private

  def stub_hubee_api_error(path, factory_trait)
    response = FactoryBot.build(:hubee_error_payload, factory_trait)

    stub_hubee_api(
      action: :post,
      path:,
      body: {},
      return_code: response['errors'][0]['code'],
      return_body: response
    )
  end

  def stub_hubee_api(action: nil, path: nil, body: nil, return_code: 200, return_body: '')
    stub_request(action, "#{Rails.application.credentials.hubee_host}/#{path}")
      .with(body:)
      .to_return(status: return_code, body: return_body.to_json, headers: { 'Content-Type' => 'application/json' })
  end
end
