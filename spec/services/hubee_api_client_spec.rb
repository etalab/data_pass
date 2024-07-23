RSpec.describe HubEEAPIClient do
  let(:hubee_api_client) { described_class.new }
  let(:organization_payload) do
    {
      'type' => 'SI',
      'companyRegister' => '21920023500014',
      'branchCode' => '92023',
      'name' => 'COMMUNE DE CLAMART',
      'code' => nil,
      'country' => 'France',
      'postalCode' => '92140',
      'territory' => 'CLAMART',
      'email' => 'example@admin.fr',
      'phoneNumber' => '0123456789',
      'status' => 'ACTIF'
    }
  end

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
        let(:response_error_missing_params) { { 'errors' => [{ 'code' => 400, 'message' => "Bad Request : Validation failed.\n[ERROR][REQUEST][POST /referential/v1/organizations @body] Object has missing required properties ([\"branchCode\",\"companyRegister\",\"email\",\"name\",\"postalCode\",\"status\",\"territory\",\"type\"])" }] } }

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
        let(:response_error_organization_already_exists) { { 'errors' => [{ 'code' => 400, 'message' => 'Organization SI-21050136700010-00000 already exists' }] } }

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

    let(:subscription_body) do
      {
        datapassId: 1,
        processCode: 'CERTDC',
        subscriber: {
          type: 'SI',
          companyRegister: '21920023500014',
          branchCode: '92023',
        },
        notificationFrequency: 'unitaire',
        validateDateTime: '2024-07-08T14:31:43+02:00',
        updateDateTime: '2024-07-08T14:31:43+02:00',
        status: 'Inactif',
        email: 'example@admin.fr',
        localAdministrator: {
          email: 'example@admin.fr',
        }
      }
    end

    context 'when subscription does not exist' do
      let(:subscription_response) do
        {
          'creationDateTime' => '2024-07-11T10:41:04.861+00:00',
          'datapassId' => 2,
          'email' => 'example@admin.fr',
          'id' => 'd8b00b31-9bb2-4fba-bd55-14776ecdc8f6',
          'localAdministrator' => { 'email' => 'example@admin.fr' },
          'notificationFrequency' => 'unitaire',
          'processCode' => 'CERTDC',
          'status' => 'Inactif',
          'subscriber' => { 'branchCode' => '83139', 'companyRegister' => '21830139800010', 'type' => 'SI' },
          'updateDateTime' => '2024-07-11T10:41:04+0000',
          'validateDateTime' => '2024-07-08T14:31:43+02:00'
        }
      end

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
        let(:response) { { 'errors' => [{ 'code' => 400, 'message' => 'Subscription CERTDC for organization SI-21920023500014-92023 already exists' }] } }

        before do
          stub_request(:post, "#{api_host}/referential/v1/subscriptions")
            .with(
              body: {},
              headers: {
                'Authorization' => "Bearer #{access_token}",
                'content-type' => 'application/json',
              }
            )
            .to_return(status: 400, body: response.to_json, headers: { 'Content-Type' => 'application/json' })
        end

        it 'renders an HubEEAPIClient::AlreadyExistsError' do
          expect { create_subscription }.to raise_error(HubEEAPIClient::AlreadyExistsError)
        end
      end

      context 'when there is missing parameters' do
        let(:response_validation_failed) do
          {
            'errors' => [{
              'code' => 400,
              'message' => "Bad Request : Validation failed.\n[ERROR][REQUEST][POST /referential/v1/subscriptions @body] Instance failed to match all required schemas (matched only 1 out of 2)\n\t* /allOf/0: Object has missing required properties ([\"datapassId\",\"localAdministrator\",\"notificationFrequency\",\"processCode\",\"subscriber\"])\t\n\t- [ERROR] Object has missing required properties ([\"datapassId\",\"localAdministrator\",\"notificationFrequency\",\"processCode\",\"subscriber\"])"
            }]
          }
        end

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
        let(:response_error_500) { { 'errors' => [{ 'code' => 500, 'message' => 'Internal Server Error' }] } }

        before do
          stub_request(:post, "#{api_host}/referential/v1/subscriptions")
            .with(
              body: subscription_body.to_json,
              headers: {
                'Authorization' => "Bearer #{access_token}",
                'content-type' => 'application/json',
              }
            )
            .to_return(status: 500, body: response_error_500.to_json, headers: {})
        end

        it 'renders an error 500' do
          expect { create_subscription }.to raise_error(Faraday::ServerError)
        end
      end
    end
  end
end
