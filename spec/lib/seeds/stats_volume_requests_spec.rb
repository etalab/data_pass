RSpec.describe Seeds::StatsVolumeRequests do
  describe '#perform' do
    subject(:perform) { described_class.new(context).perform }

    let(:organizations) { Seeds::ReferenceOrganizations.new }
    let(:accounts) { Seeds::TestAccounts.new(organizations) }
    let(:context) { Seeds::Context.new(organizations:, accounts:, requests: Seeds::AuthorizationRequestInState.new(accounts)) }

    before do
      Seeds.new.create_data_providers
      organizations.perform
      accounts.perform
      allow(Rails.logger).to receive(:error).and_call_original
    end

    it 'creates requests for every provider' do
      perform

      providers_with_requests = AuthorizationRequest.all.map { |authorization_request| authorization_request.definition.provider.slug }.uniq

      expect(providers_with_requests).to include(*described_class::AUTHORIZATION_TYPES_PER_PROVIDER.keys)
    end

    it 'skips no request' do
      perform

      expect(Rails.logger).not_to have_received(:error)
    end
  end
end
