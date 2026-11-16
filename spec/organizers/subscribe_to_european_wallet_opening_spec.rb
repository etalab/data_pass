RSpec.describe SubscribeToEuropeanWalletOpening do
  describe '.call' do
    subject(:subscribe) { described_class.call(email:, profile:, honeypot:, registry_open:) }

    let(:email) { 'jean.dupont@example.com' }
    let(:profile) { 'intermediary' }
    let(:honeypot) { nil }
    let(:registry_open) { false }

    context 'with a valid subscription' do
      it { is_expected.to be_success }

      it 'records the subscriber with its profile' do
        expect { subscribe }.to change(EuropeanWalletSubscriber, :count).by(1)

        expect(EuropeanWalletSubscriber.last).to have_attributes(email:, profile:)
      end
    end

    context 'when the address is already subscribed' do
      let!(:subscriber) { create(:european_wallet_subscriber, email:, profile: 'organization') }
      let(:email) { 'Jean.Dupont@example.com' }

      it { is_expected.to be_success }

      it 'updates the profile without creating a duplicate' do
        expect { subscribe }.not_to change(EuropeanWalletSubscriber, :count)

        expect(subscriber.reload.profile).to eq('intermediary')
      end
    end

    context 'when the honeypot is filled' do
      let(:honeypot) { 'https://spam.example.com' }

      it { is_expected.to be_failure }

      it 'is reported as spam' do
        expect(subscribe.spam).to be(true)
      end

      it 'records nothing' do
        expect { subscribe }.not_to change(EuropeanWalletSubscriber, :count)
      end
    end

    context 'when the address is invalid' do
      let(:email) { 'jean.dupont' }

      it { is_expected.to be_failure }

      it 'exposes the error on the address' do
        expect(subscribe.subscriber.errors).to be_of_kind(:email, :invalid)
      end

      it 'records nothing' do
        expect { subscribe }.not_to change(EuropeanWalletSubscriber, :count)
      end
    end

    context 'when no profile is chosen' do
      let(:profile) { nil }

      it { is_expected.to be_failure }

      it 'exposes the error on the profile' do
        expect(subscribe.subscriber.errors).to be_of_kind(:profile, :blank)
      end
    end

    context 'when an already subscribed address comes back without a profile' do
      let!(:subscriber) { create(:european_wallet_subscriber, email:, profile: 'organization') }
      let(:profile) { nil }

      it { is_expected.to be_failure }

      it 'keeps the previous profile' do
        subscribe

        expect(subscriber.reload.profile).to eq('organization')
      end
    end

    context 'when the registry is open' do
      let(:registry_open) { true }

      context 'with the organization profile, no longer offered' do
        let(:profile) { 'organization' }

        it { is_expected.to be_failure }

        it 'exposes the error on the profile' do
          expect(subscribe.subscriber.errors).to be_of_kind(:profile, :inclusion)
        end
      end

      context 'with a profile still offered' do
        let(:profile) { 'attestation_provider' }

        it { is_expected.to be_success }
      end
    end

    context 'when the database refuses the record' do
      before do
        allow(EuropeanWalletSubscriber).to receive(:find_or_initialize_by).and_raise(ActiveRecord::ConnectionNotEstablished)
        allow(Sentry).to receive(:capture_exception)
      end

      it { is_expected.to be_failure }

      it 'is reported as not saved' do
        expect(subscribe.not_saved).to be(true)
      end

      it 'notifies Sentry' do
        subscribe

        expect(Sentry).to have_received(:capture_exception).with(an_instance_of(ActiveRecord::ConnectionNotEstablished))
      end
    end

    context 'when another request records the same address at the same time' do
      before do
        create(:european_wallet_subscriber, email:, profile: 'organization')
        allow(EuropeanWalletSubscriber).to receive(:find_or_initialize_by).and_return(EuropeanWalletSubscriber.new(email:))
      end

      it { is_expected.to be_success }

      it 'updates the existing subscriber' do
        subscribe

        expect(EuropeanWalletSubscriber.find_by(email:).profile).to eq('intermediary')
      end
    end
  end
end
