RSpec.describe EnqueueOrganizationINSEERefresh, type: :interactor do
  subject(:interactor) { described_class.call(organization:) }

  context 'when the organization is due for a refresh' do
    let(:organization) { create(:organization, last_insee_payload_updated_at: nil) }

    it 'enqueues a refresh' do
      expect { interactor }.to have_enqueued_job(UpdateOrganizationINSEEPayloadJob).with(organization.id)
    end
  end

  context 'when the organization is foreign' do
    let(:organization) { create(:organization, :foreign) }

    it 'does not enqueue anything, so that the job does not take a throttled slot for nothing' do
      expect { interactor }.not_to have_enqueued_job(UpdateOrganizationINSEEPayloadJob)
    end
  end
end
