RSpec.describe ExecuteAuthorizationRequestBridge do
  subject(:execute) { described_class.call(authorization_request:, state_machine_event: :approve) }

  describe 'static forms resolved by naming convention' do
    {
      hubee_cert_dc: HubEECertDCBridge,
      hubee_dila: HubEEDilaBridge,
      api_captchetat: APICaptchEtatBridge,
    }.each do |trait, bridge_class|
      context "with a #{trait} authorization request" do
        let(:authorization_request) { build(:authorization_request, trait) }

        it "enqueues #{bridge_class}" do
          expect(bridge_class).to receive(:perform_later).with(authorization_request, :approve)

          execute
        end
      end
    end

    context 'with a static form without bridge' do
      let(:authorization_request) { build(:authorization_request, :api_entreprise) }

      it 'enqueues nothing and succeeds' do
        expect { execute }.not_to have_enqueued_job

        expect(execute).to be_a_success
      end
    end
  end

  describe 'dynamic forms resolved from their declaration' do
    let(:authorization_request) { AuthorizationRequest.const_get(habilitation_type.uid.classify).new }

    after { AuthorizationDefinition.reset! }

    context 'when the HabilitationType declares an existing bridge' do
      let!(:habilitation_type) { create(:habilitation_type, bridge_class_name: 'HubEEDilaBridge') }

      it 'enqueues the declared bridge' do
        expect(HubEEDilaBridge).to receive(:perform_later).with(authorization_request, :approve)

        execute
      end
    end

    context 'when the bridge is declared after the definition was memoized on the class' do
      let!(:habilitation_type) { create(:habilitation_type) }
      let(:runtime_class) { AuthorizationRequest.const_get(habilitation_type.uid.classify) }
      let(:authorization_request) { runtime_class.new }

      before do
        runtime_class.definition
        habilitation_type.update!(bridge_class_name: 'HubEEDilaBridge')
      end

      it 'enqueues the freshly declared bridge' do
        expect(HubEEDilaBridge).to receive(:perform_later).with(authorization_request, :approve)

        execute
      end
    end

    context 'when the HabilitationType declares no bridge' do
      let!(:habilitation_type) { create(:habilitation_type) }

      it 'enqueues nothing and succeeds' do
        expect { execute }.not_to have_enqueued_job

        expect(execute).to be_a_success
      end
    end

    context 'when the declared bridge does not resolve' do
      let!(:habilitation_type) { create(:habilitation_type, bridge_class_name: 'NopeBridge') }

      it 'notifies Sentry without enqueueing nor failing' do
        expect(Sentry).to receive(:capture_message).with(/NopeBridge/, level: :error)

        expect { execute }.not_to have_enqueued_job

        expect(execute).to be_a_success
      end
    end

    context 'when the declared class is not a bridge' do
      let!(:habilitation_type) { create(:habilitation_type, bridge_class_name: 'User') }

      it 'notifies Sentry without enqueueing nor failing' do
        expect(Sentry).to receive(:capture_message).with(/User/, level: :error)

        expect { execute }.not_to have_enqueued_job

        expect(execute).to be_a_success
      end
    end
  end
end
