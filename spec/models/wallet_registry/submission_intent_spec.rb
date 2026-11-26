RSpec.describe WalletRegistry::SubmissionIntent do
  subject(:intent) { described_class.from_session(described_class.issue(authorization_request:, user:, now: issued_at).to_session) }

  let(:authorization_request) { build_stubbed(:authorization_request, :registre_wallet) }
  let(:user) { build_stubbed(:user) }
  let(:issued_at) { Time.zone.parse('2026-11-19 10:00:00.5') }

  describe '#valid_for?' do
    def valid_for?(request: authorization_request, person: user, nonce: intent.nonce, now: issued_at + 1.minute)
      intent.valid_for?(authorization_request: request, user: person, nonce:, now:)
    end

    it { expect(valid_for?).to be true }
    it { expect(valid_for?(nonce: 'another-nonce')).to be false }
    it { expect(valid_for?(nonce: nil)).to be false }
    it { expect(valid_for?(request: build_stubbed(:authorization_request, :registre_wallet))).to be false }
    it { expect(valid_for?(person: build_stubbed(:user))).to be false }
    it { expect(valid_for?(now: issued_at + 16.minutes)).to be false }
  end

  describe '#certified_after_issue?' do
    it 'accepts a certification made after the click, at the second' do
      expect(intent.certified_after_issue?(Time.zone.parse('2026-11-19 10:00:00'))).to be true
    end

    it 'refuses a certification made before the click' do
      expect(intent.certified_after_issue?(issued_at - 1.minute)).to be false
    end

    it { expect(intent.certified_after_issue?(nil)).to be false }
  end
end
