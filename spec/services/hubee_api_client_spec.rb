RSpec.describe HubEEAPIClient do
  let(:hubee_api_client) { described_class.new }

  let(:hubee_auth_url) { Rails.application.credentials.hubee_auth_url }
  let(:api_host) { Rails.application.credentials.hubee_host }
  let(:access_token) { 'access_token' }

  before do
    stub_request(:post, hubee_auth_url)
      .to_return(status: 200, body: { 'access_token' => 'access_token' }.to_json, headers: { 'Content-Type' => 'application/json' })
  end

  describe '#get_organization' do
    subject(:get_organization) { hubee_api_client.get_organization(siret, code_commune) }

    let(:siret) { '21920023500014' }
    let(:code_commune) { '75001' }

    context 'when organization already exists in HubEE' do
      before do
        stub_request(:get, "#{api_host}/referential/v1/organizations/SI-#{siret}-#{code_commune}")
          .with(
            headers: { 'Authorization' => "Bearer #{access_token}" }
          )
          .to_return(status: 200, body: organization_payload.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'calls the stubbed request' do
        get_organization

        expect(a_request(:get, "#{api_host}/referential/v1/organizations/SI-#{siret}-#{code_commune}")
                 .with(headers: { 'Authorization' => "Bearer #{access_token}" })).to have_been_requested
      end

      it 'returns the HubEE organization payload' do
        expect(get_organization).to eq(organization_payload)
      end
    end

    context 'when organization does not exist in HubEE' do
      context 'when it returns a 404 not found error' do
        before do
          stub_request(:get, "#{api_host}/referential/v1/organizations/SI-#{siret}-#{code_commune}")
            .with(
              headers: { 'Authorization' => "Bearer #{access_token}" }
            )
            .to_return(status: 404, body: '', headers: { 'Content-Type' => 'application/json' })
        end

        it 'raises a Faraday::ResourceNotFound error' do
          expect { get_organization }.to raise_error(Faraday::ResourceNotFound)
        end
      end
    end
  end

  describe '#create_organization' do
    subject(:create_organization) { hubee_api_client.create_organization(organization_payload) }

    context 'when organization does not exists in HubEE' do
      before do
        stub_request(:post, "#{api_host}/referential/v1/organizations")
          .with(
            body: organization_payload.to_json,
            headers: {
              'Authorization' => "Bearer #{access_token}",
              'Content-Type' => 'application/json',
              'Tag' => 'Portail HubEE',
            }
          )
          .to_return(status: 200, body: organization_payload.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'creates the organization - Render 200' do
        expect(create_organization).to eq(organization_payload)
      end
    end

    context 'when it renders a 400 Bad Request Error' do
      context 'when there is missing parameters' do
        before do
          stub_request(:post, "#{api_host}/referential/v1/organizations")
            .with(
              body: {},
              headers: {
                'Authorization' => "Bearer #{access_token}",
                'content-type' => 'application/json',
                'tag' => 'Portail HubEE'
              }
            )
            .to_return(status: 400, body: response_error_missing_params.to_json, headers: { 'Content-Type' => 'application/json' })
        end

        it 'raises a Faraday BadRequestError' do
          expect { create_organization }.to raise_error(Faraday::BadRequestError)
        end
      end

      context 'when organization already exists' do
        before do
          stub_request(:post, "#{api_host}/referential/v1/organizations")
            .with(
              body: {},
              headers: {
                'Authorization' => "Bearer #{access_token}",
                'content-type' => 'application/json',
                'tag' => 'Portail HubEE'
              }
            )
            .to_return(status: 400, body: response_error_organization_already_exists.to_json, headers: { 'Content-Type' => 'application/json' })
        end

        it 'renders an AlreadyExistsError' do
          expect { create_organization }.to raise_error(HubEEAPIClient::AlreadyExistsError)
        end
      end
    end
  end

  describe '#create_subscription' do
    subject(:create_subscription) { hubee_api_client.create_subscription(subscription_body) }

    context 'when subscription does not exist' do
      before do
        stub_request(:post, "#{api_host}/referential/v1/subscriptions")
          .with(
            body: subscription_body.to_json,
            headers: {
              'Authorization' => "Bearer #{access_token}",
              'content-type' => 'application/json',
            }
          )
          .to_return(status: 201, body: subscription_response.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'calls the stubbed request' do
        create_subscription

        expect(a_request(:post, "#{api_host}/referential/v1/subscriptions")
                 .with(
                   body: subscription_body.to_json,
                   headers: {
                     'Authorization' => "Bearer #{access_token}",
                     'content-type' => 'application/json',
                   }
                 )).to have_been_requested
      end

      it 'creates the subscription - Render 201' do
        expect(create_subscription).to eq(subscription_response)
      end
    end

    context 'when subscription failed' do
      context 'when subscription already exists' do
        before do
          stub_request(:post, "#{api_host}/referential/v1/subscriptions")
            .with(
              body: {},
              headers: {
                'Authorization' => "Bearer #{access_token}",
                'content-type' => 'application/json',
              }
            )
            .to_return(status: 400, body: response_subscription_already_exists.to_json, headers: { 'Content-Type' => 'application/json' })
        end

        it 'renders an HubEEAPIClient::AlreadyExistsError' do
          expect { create_subscription }.to raise_error(HubEEAPIClient::AlreadyExistsError)
        end
      end

      context 'when there is missing parameters' do
        before do
          stub_request(:post, "#{api_host}/referential/v1/subscriptions")
            .with(
              body: {},
              headers: {
                'Authorization' => "Bearer #{access_token}",
                'content-type' => 'application/json',
              }
            )
            .to_return(status: 400, body: response_validation_failed.to_json, headers: { 'Content-Type' => 'application/json' })
        end

        it 'renders a 400 BadRequest Error' do
          expect { create_subscription }.to raise_error(Faraday::BadRequestError)
        end
      end

      context 'when there is an Internal server error' do
        before do
          stub_request(:post, "#{api_host}/referential/v1/subscriptions")
            .with(
              body: subscription_body.to_json,
              headers: {
                'Authorization' => "Bearer #{access_token}",
                'content-type' => 'application/json',
              }
            )
            .to_return(status: 500, body: subscription_response_error_500.to_json, headers: {})
        end

        it 'renders an error 500' do
          expect { create_subscription }.to raise_error(Faraday::ServerError)
        end
      end
    end
  end
end
