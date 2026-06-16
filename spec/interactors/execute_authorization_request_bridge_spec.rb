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

  describe 'dynamic forms resolved by naming convention' do
    after { AuthorizationDefinition.reset! }

    context 'when the dynamic class has a conventionally named bridge' do
      let!(:habilitation_type) { create(:habilitation_type, name: 'Boursiers') }
      let(:authorization_request) { AuthorizationRequest.const_get(habilitation_type.uid.classify).new }

      it 'enqueues the matching bridge' do
        expect(BoursiersDynBridge).to receive(:perform_later).with(authorization_request, :approve)

        execute
      end
    end

    context 'when the dynamic class has no matching bridge' do
      let!(:habilitation_type) { create(:habilitation_type) }
      let(:authorization_request) { AuthorizationRequest.const_get(habilitation_type.uid.classify).new }

      it 'enqueues nothing and succeeds' do
        expect { execute }.not_to have_enqueued_job

        expect(execute).to be_a_success
      end
    end
  end
end
