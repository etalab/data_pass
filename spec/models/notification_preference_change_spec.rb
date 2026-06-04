RSpec.describe NotificationPreferenceChange do
  describe 'creation' do
    let(:user) { create(:user) }

    it 'is valid with valid attributes' do
      change = described_class.new(
        user:,
        authorization_definition_id: 'api_entreprise',
        kind: 'submit',
        enabled: false,
        source: 'email_token',
      )

      expect(change).to be_valid
    end

    it 'persists successfully' do
      expect {
        described_class.create!(
          user:,
          authorization_definition_id: 'api_entreprise',
          kind: 'messages',
          enabled: false,
          source: 'email_token',
        )
      }.to change(described_class, :count).by(1)
    end
  end

  describe 'kind validation' do
    let(:user) { create(:user) }

    it 'accepts submit' do
      change = described_class.new(user:, authorization_definition_id: 'api_entreprise', kind: 'submit', enabled: false, source: 'email_token')
      expect(change).to be_valid
    end

    it 'accepts messages' do
      change = described_class.new(user:, authorization_definition_id: 'api_entreprise', kind: 'messages', enabled: false, source: 'email_token')
      expect(change).to be_valid
    end

    it 'rejects unknown kind' do
      change = described_class.new(user:, authorization_definition_id: 'api_entreprise', kind: 'approve', enabled: false, source: 'email_token')
      expect(change).not_to be_valid
      expect(change.errors[:kind]).to be_present
    end
  end

  describe 'source validation' do
    let(:user) { create(:user) }

    it 'accepts email_token' do
      change = described_class.new(user:, authorization_definition_id: 'api_entreprise', kind: 'submit', enabled: false, source: 'email_token')
      expect(change).to be_valid
    end

    it 'rejects unknown source' do
      change = described_class.new(user:, authorization_definition_id: 'api_entreprise', kind: 'submit', enabled: false, source: 'manual')
      expect(change).not_to be_valid
      expect(change.errors[:source]).to be_present
    end
  end
end
