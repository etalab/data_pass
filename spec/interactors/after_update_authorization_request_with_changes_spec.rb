RSpec.describe AfterUpdateAuthorizationRequestWithChanges, type: :interactor do
  subject(:call) { described_class.call(authorization_request:, changelog:, user: authorization_request.applicant, event_name: 'update_by_api', event_entity: :changelog) }

  let(:authorization_request) { create(:authorization_request, :api_entreprise) }

  context 'with a changelog' do
    let(:changelog) { CreateAuthorizationRequestChangelog.call(authorization_request:).changelog }

    it 'creates the update_by_api event' do
      expect { call }.to change { authorization_request.events_without_bulk_update.where(name: 'update_by_api').count }.by(1)
    end
  end

  context 'without changelog' do
    let(:changelog) { nil }

    it 'creates no event' do
      expect { call }.not_to change(AuthorizationRequestEvent, :count)
    end
  end
end
