RSpec.describe DirigeantVerificationFact do
  let(:user) { create(:user) }
  let(:organization) { user.current_organization }
  let(:fact) { described_class.build(user:, organization:, verified_at: 10.minutes.ago) }

  describe '#valid_for?' do
    it 'is valid for the same user and the same organization' do
      expect(fact.valid_for?(user:, organization:)).to be true
    end

    it 'is not valid for another user' do
      expect(fact.valid_for?(user: create(:user), organization:)).to be false
    end

    it 'is not valid once the user has switched to another organization' do
      expect(fact.valid_for?(user:, organization: create(:organization))).to be false
    end

    it 'expires after an hour' do
      expect(fact.valid_for?(user:, organization:, now: 2.hours.from_now)).to be false
    end

    it 'is not valid without a user' do
      expect(fact.valid_for?(user: nil, organization:)).to be false
    end
  end

  describe 'round trip through the session' do
    it 'keeps the user, the organization and the time' do
      restored = described_class.from_session(fact.to_session.as_json)

      expect(restored.valid_for?(user:, organization:)).to be true
    end

    it 'stores nothing that names the person' do
      expect(fact.to_session.keys).to contain_exactly('user_id', 'siret', 'verified_at')
    end

    it 'gives nothing back from an empty session' do
      expect(described_class.from_session(nil)).to be_nil
    end
  end
end
