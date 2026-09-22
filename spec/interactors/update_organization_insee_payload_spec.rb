RSpec.describe UpdateOrganizationINSEEPayload, type: :interactor do
  subject(:interactor) { described_class.call(organization:, update_organization_insee_payload_now: true) }

  let(:organization) { create(:organization, last_insee_payload_updated_at: nil) }
  let(:insee_sirene_api_client) { instance_double(INSEESireneAPIClient) }

  before do
    allow(INSEESireneAPIClient).to receive(:new).and_return(insee_sirene_api_client)
    allow(Sentry).to receive(:capture_exception)
  end

  context 'when the SIRET does not exist' do
    before do
      allow(insee_sirene_api_client).to receive(:etablissement).and_raise(INSEESireneAPIClient::EntityNotFoundError)
    end

    it { is_expected.to be_a_failure }

    it 'returns an error related to INSEE not found error' do
      expect(interactor.error).to eq(:insee_entity_not_found)
    end
  end

  context 'when INSEE is unavailable' do
    before do
      allow(insee_sirene_api_client).to receive(:etablissement).and_raise(AbstractINSEEAPIClient::UnavailableError)
    end

    it { is_expected.to be_a_success }

    it 'enqueues the payload update instead of refusing the organization' do
      expect { interactor }.to have_enqueued_job(UpdateOrganizationINSEEPayloadJob).with(organization.id)
    end

    it 'reports to Sentry as a warning' do
      interactor

      expect(Sentry).to have_received(:capture_exception).with(
        an_instance_of(AbstractINSEEAPIClient::UnavailableError),
        level: :warning,
      )
    end
  end

  context 'when INSEE answers with an unexpected status' do
    before do
      allow(insee_sirene_api_client).to receive(:etablissement).and_raise(Faraday::ServerError.new('boom'))
    end

    it { is_expected.to be_a_success }

    it 'enqueues the payload update instead of refusing the organization' do
      expect { interactor }.to have_enqueued_job(UpdateOrganizationINSEEPayloadJob).with(organization.id)
    end
  end

  context 'when INSEE answers with an invalid payload' do
    before do
      allow(insee_sirene_api_client).to receive(:etablissement).and_raise(INSEESireneAPIClient::InvalidResponseError)
    end

    it { is_expected.to be_a_success }

    it 'enqueues the payload update instead of refusing the organization' do
      expect { interactor }.to have_enqueued_job(UpdateOrganizationINSEEPayloadJob).with(organization.id)
    end
  end
end
