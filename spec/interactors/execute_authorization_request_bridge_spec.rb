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

  describe 'dynamic forms resolved by their blocks' do
    before do
      AuthorizationDefinition.reset!
      AuthorizationRequestForm.reset!
    end

    after do
      AuthorizationDefinition.reset!
      AuthorizationRequestForm.reset!
    end

    context 'when the form carries the CNOUS proactivité block, whatever its name' do
      let!(:habilitation_type) do
        create(:habilitation_type,
          name: 'Test proactividad',
          blocks: [{ 'name' => 'basic_infos' }, { 'name' => 'cnous_data_extraction_criteria' }, { 'name' => 'contacts' }],
          contact_types: ['contact_technique'])
      end
      let(:authorization_request) { AuthorizationRequest.const_get(habilitation_type.uid.classify).new }

      it 'enqueues the HubEE proactivité bridge regardless of the class name' do
        expect(HubEEProactiviteBridge).to receive(:perform_later).with(authorization_request, :approve)

        execute
      end
    end

    context 'when the form does not carry a block tied to a bridge' do
      let!(:habilitation_type) { create(:habilitation_type) }
      let(:authorization_request) { AuthorizationRequest.const_get(habilitation_type.uid.classify).new }

      it 'enqueues nothing and succeeds' do
        expect { execute }.not_to have_enqueued_job

        expect(execute).to be_a_success
      end
    end
  end
end
