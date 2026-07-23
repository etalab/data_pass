RSpec.describe LocalSignInPolicy do
  def stub_tokens(tokens)
    allow(Rails.application.credentials).to receive(:local_sign_in_tokens).and_return(tokens)
  end

  def stub_env(name)
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new(name))
  end

  describe '#available?' do
    context 'when the environment is production' do
      it 'returns false even with a valid token' do
        stub_env('production')
        stub_tokens(dgfip: 's3cret')

        policy = described_class.new(submitted_token: 's3cret')

        expect(policy.available?).to be false
      end
    end

    context 'when no token is configured' do
      it 'returns true (bypass stays open)' do
        stub_tokens(nil)

        expect(described_class.new.available?).to be true
      end
    end

    context 'when tokens are configured' do
      before { stub_tokens(dgfip: 'dgfip-token', api_entreprise: 'entreprise-token') }

      it 'returns false without any submitted token nor cookie' do
        expect(described_class.new.available?).to be false
      end

      it 'returns true with a token matching one of the providers' do
        expect(described_class.new(submitted_token: 'entreprise-token').available?).to be true
      end

      it 'returns false with a token matching no provider' do
        expect(described_class.new(submitted_token: 'nope').available?).to be false
      end

      it 'returns true with a valid unlocked cookie token' do
        expect(described_class.new(unlocked_token: 'dgfip-token').available?).to be true
      end
    end
  end

  describe '#matched_provider' do
    before { stub_tokens(dgfip: 'dgfip-token', api_entreprise: 'entreprise-token') }

    it 'returns the provider whose token was submitted' do
      expect(described_class.new(submitted_token: 'entreprise-token').matched_provider).to eq(:api_entreprise)
    end

    it 'falls back to the provider of the unlocked cookie token' do
      expect(described_class.new(unlocked_token: 'dgfip-token').matched_provider).to eq(:dgfip)
    end

    it 'returns nil when nothing matches' do
      expect(described_class.new(submitted_token: 'nope').matched_provider).to be_nil
    end
  end

  describe '#unlockable_token' do
    before { stub_tokens(dgfip: 'dgfip-token') }

    it 'returns the submitted token when it matches a provider' do
      expect(described_class.new(submitted_token: 'dgfip-token').unlockable_token).to eq('dgfip-token')
    end

    it 'returns nil when the submitted token matches no provider' do
      expect(described_class.new(submitted_token: 'nope').unlockable_token).to be_nil
    end

    it 'returns nil when the token only comes from the cookie' do
      expect(described_class.new(unlocked_token: 'dgfip-token').unlockable_token).to be_nil
    end
  end
end
