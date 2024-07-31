RSpec.describe HubEEAPIClient do
  let(:hubee_api_client) { described_class.new }

  let(:api_host) { Rails.application.credentials.hubee_host }
  let(:access_token) { 'some_access_token' }

  let(:authorization_request) { create(:authorization_request, :hubee_cert_dc, :validated, organization:) }
  let(:organization) { create(:organization, siret: '21920023500014') }

  before do
    stub_hubee_auth
  end

  describe '#get_organization' do
    subject(:get_organization) { hubee_api_client.get_organization(siret, code_commune) }

    let(:siret) { authorization_request.organization.siret }
    let(:code_commune) { authorization_request.organization.code_commune }
    let(:organization_payload) { build(:hubee_organization_payload, organization:, authorization_request:) }

    context 'when organization already exists in HubEE' do
      let!(:stubbed_hubee_get_organization_request) do
        stub_hubee_get_organization(siret, code_commune, organization_payload.with_indifferent_access)
      end

      it 'calls the stubbed request' do
        get_organization

        expect(stubbed_hubee_get_organization_request).to have_been_requested
      end

      it 'returns the HubEE organization payload' do
        expect(get_organization).to eq(organization_payload.with_indifferent_access)
      end
    end

    context 'when organization does not exist in HubEE' do
      context 'when it returns a 404 not found error' do
        before do
          stub_hubee_get_organization_error(siret, code_commune)
        end

        it 'raises a Faraday::ResourceNotFound error' do
          expect { get_organization }.to raise_error(Faraday::ResourceNotFound)
        end
      end
    end
  end

  describe '#create_organization' do
    subject(:create_organization) { hubee_api_client.create_organization(organization_payload) }

    let(:organization_payload) { build(:hubee_organization_payload) }

    context 'when organization does not exists in HubEE' do
      before do
        stub_hubee_create_organization(organization_payload)
      end

      it 'creates the organization' do
        expect(create_organization).to eq(organization_payload)
      end
    end

    context 'when it renders a 400 Bad Request Error' do
      context 'when there is missing parameters' do
        before do
          stub_hubee_create_organization_error(:organization_missing_params)
        end

        it 'raises a Faraday BadRequestError' do
          expect { create_organization }.to raise_error(Faraday::BadRequestError)
        end
      end

      context 'when organization already exists' do
        before do
          stub_hubee_create_organization_error(:organization_already_exists)
        end

        it 'renders an AlreadyExistsError' do
          expect { create_organization }.to raise_error(HubEEAPIClient::AlreadyExistsError)
        end
      end
    end
  end

  describe '#create_subscription' do
    subject(:create_subscription) { hubee_api_client.create_subscription(subscription_body) }

    let(:subscription_body) { build(:hubee_subscription_payload, :cert_dc, authorization_request:, organization:) }
    let(:subscription_response) { build(:hubee_subscription_response_payload).merge(subscription_body) }

    context 'when subscription does not exist' do
      let!(:stubbed_hubee_create_subscription_request) do
        stub_hubee_create_subscription(subscription_body)
      end

      it 'calls the stubbed request' do
        create_subscription

        expect(stubbed_hubee_create_subscription_request).to have_been_requested
      end

      it 'creates the subscription' do
        expect(create_subscription).to eq(subscription_response)
      end
    end

    context 'when subscription failed' do
      context 'when subscription already exists' do
        before do
          stub_hubee_create_subscription_error(:subscription_already_exists)
        end

        it 'renders an HubEEAPIClient::AlreadyExistsError' do
          expect { create_subscription }.to raise_error(HubEEAPIClient::AlreadyExistsError)
        end
      end

      context 'when there is missing parameters' do
        before do
          stub_hubee_create_subscription_error(:subscription_validation_failed)
        end

        it 'renders a 400 BadRequest Error' do
          expect { create_subscription }.to raise_error(Faraday::BadRequestError)
        end
      end

      context 'when there is an Internal server error' do
        before do
          stub_hubee_create_subscription_error(:internal_server_error)
        end

        it 'renders an error 500' do
          expect { create_subscription }.to raise_error(Faraday::ServerError)
        end
      end
    end
  end
end
