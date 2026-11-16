RSpec.describe EuropeanWalletSubscriber do
  describe 'email' do
    it 'is stored downcased and without surrounding spaces' do
      subscriber = create(:european_wallet_subscriber, email: '  Jean.Dupont@Example.COM ')

      expect(subscriber.reload.email).to eq('jean.dupont@example.com')
    end

    it 'is encrypted in the database' do
      subscriber = create(:european_wallet_subscriber, email: 'jean.dupont@example.com')

      raw_email = described_class.connection.select_value(
        described_class.where(id: subscriber.id).select(:email).to_sql
      )

      expect(raw_email).not_to include('jean.dupont')
    end

    it 'can be found whatever its case' do
      subscriber = create(:european_wallet_subscriber, email: 'jean.dupont@example.com')

      expect(described_class.find_by(email: 'JEAN.DUPONT@example.com')).to eq(subscriber)
    end

    it 'is unique whatever its case' do
      create(:european_wallet_subscriber, email: 'jean.dupont@example.com')
      duplicate = build(:european_wallet_subscriber, email: 'Jean.Dupont@example.com')

      expect(duplicate).not_to be_valid
      expect(duplicate.errors).to be_of_kind(:email, :taken)
    end

    it 'gives a single error when left empty' do
      subscriber = build(:european_wallet_subscriber, email: '')

      subscriber.validate

      expect(subscriber.errors.details[:email]).to eq([{ error: :blank }])
    end

    it 'must look like an email address' do
      subscriber = build(:european_wallet_subscriber, email: 'jean.dupont')

      expect(subscriber).not_to be_valid
      expect(subscriber.errors).to be_of_kind(:email, :invalid)
    end

    it 'is not written in clear in the logs' do
      subscriber = build(:european_wallet_subscriber, email: 'jean.dupont@example.com')

      expect(subscriber.inspect).not_to include('jean.dupont')
    end

    it 'is filtered from the logged request parameters' do
      described_class.new
      filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)

      filtered_params = filter.filter('european_wallet_subscriber' => { 'email' => 'jean.dupont@example.com' })

      expect(filtered_params.dig('european_wallet_subscriber', 'email')).to eq('[FILTERED]')
    end
  end

  describe 'profile' do
    it 'must be chosen' do
      subscriber = build(:european_wallet_subscriber, profile: nil)

      expect(subscriber).not_to be_valid
      expect(subscriber.errors).to be_of_kind(:profile, :blank)
    end

    it 'must be one of the three profiles' do
      subscriber = build(:european_wallet_subscriber, profile: 'particulier')

      expect(subscriber).not_to be_valid
      expect(subscriber.errors).to be_of_kind(:profile, :inclusion)
    end
  end

  describe '.offered_profiles' do
    it 'offers the three profiles before the registry opens' do
      expect(described_class.offered_profiles(registry_open: false)).to eq(%w[organization intermediary attestation_provider])
    end

    it 'no longer offers the organization profile once the registry is open' do
      expect(described_class.offered_profiles(registry_open: true)).to eq(%w[intermediary attestation_provider])
    end
  end

  describe '#external_profile' do
    it 'gives the value used by the contact list' do
      expect(build(:european_wallet_subscriber, profile: 'organization').external_profile).to eq('organisation')
      expect(build(:european_wallet_subscriber, profile: 'intermediary').external_profile).to eq('intermediaire')
      expect(build(:european_wallet_subscriber, profile: 'attestation_provider').external_profile).to eq('fournisseur_attestations')
    end
  end

  describe 'unsubscribe token' do
    it 'finds the subscriber back' do
      subscriber = create(:european_wallet_subscriber)
      token = subscriber.generate_token_for(:unsubscribe)

      expect(described_class.find_by_token_for(:unsubscribe, token)).to eq(subscriber)
    end

    it 'finds nothing once the subscriber is deleted' do
      subscriber = create(:european_wallet_subscriber)
      token = subscriber.generate_token_for(:unsubscribe)
      subscriber.destroy!

      expect(described_class.find_by_token_for(:unsubscribe, token)).to be_nil
    end
  end
end
