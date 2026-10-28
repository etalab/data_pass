RSpec.describe RefreshOrganizationINSEENow, type: :interactor do
  subject(:interactor) { described_class.call(organization:) }

  let(:organization) { create(:organization, last_insee_payload_updated_at: nil) }
  let(:job) { instance_double(UpdateOrganizationINSEEPayloadJob, perform: nil) }

  before { allow(UpdateOrganizationINSEEPayloadJob).to receive(:new).and_return(job) }

  context 'when the organization is due for a refresh' do
    it 'refreshes it synchronously' do
      interactor

      expect(job).to have_received(:perform).with(organization.id)
    end
  end

  context 'when the organization is foreign' do
    let(:organization) { create(:organization, :foreign) }

    it 'does not call INSEE' do
      interactor

      expect(job).not_to have_received(:perform)
    end
  end

  context 'when INSEE is unavailable' do
    before do
      allow(job).to receive(:perform).and_raise(AbstractINSEEAPIClient::UnavailableError)
      allow(Sentry).to receive(:capture_exception)
    end

    it 'does not fail the interactor and reports the error' do
      expect(interactor).to be_a_success
      expect(Sentry).to have_received(:capture_exception)
    end
  end
end
