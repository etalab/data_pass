RSpec.describe Seeds::Stats do
  describe '#perform' do
    subject(:perform) { described_class.new(seeds).perform }

    let(:seeds) { Seeds.new }

    before do
      seeds.create_data_providers
      seeds.send(:organizations).perform
      seeds.send(:accounts).perform
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
