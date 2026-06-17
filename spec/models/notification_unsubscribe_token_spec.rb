RSpec.describe NotificationUnsubscribeToken do
  let(:user) { create(:user) }
  let(:definition_id) { 'api_entreprise' }
  let(:kind) { 'submit' }

  describe '.generate and .decode round-trip' do
    it 'decodes a generated token with correct payload' do
      token = described_class.generate(user:, definition_id:, kind:)
      payload = described_class.decode(token)

      expect(payload[:user_id]).to eq(user.id)
      expect(payload[:definition_id]).to eq(definition_id)
      expect(payload[:kind]).to eq(kind)
    end
  end

  describe '.decode' do
    it 'returns nil for a falsified token' do
      expect(described_class.decode('invalide.token.falsifie')).to be_nil
    end

    it 'returns nil for an expired token' do
      token = described_class.generate(user:, definition_id:, kind:)

      travel_to(described_class::EXPIRES_IN.from_now + 1.day) do
        expect(described_class.decode(token)).to be_nil
      end
    end
  end
end
