RSpec.describe HubEEProactiviteBridge do
  subject(:perform) { described_class.new.perform(authorization_request, 'approve') }

  include_context 'with mocked hubee API client'

  let!(:habilitation_type) do
    create(:habilitation_type,
      name: 'Test proactividad',
      contact_types: ['contact_technique'],
      blocks: [{ 'name' => 'basic_infos' }, { 'name' => 'cnous_data_extraction_criteria' }, { 'name' => 'contacts' }])
  end
  let(:organization) { create(:organization, siret: '21920023500014') }
  let(:authorization_request) do
    create(:authorization_request, :validated,
      type: habilitation_type.authorization_request_type,
      form_uid: habilitation_type.slug,
      organization:,
      external_provider_id: nil)
  end
  let(:organization_payload) do
    build(:hubee_organization_payload, organization:,
      email: 'jean.dupont.contact_technique@gouv.fr',
      phoneNumber: '0836656565')
  end
  let(:subscription_response) { build(:hubee_subscription_response_payload, id: hubee_subscription_id) }
  let(:hubee_subscription_id) { '1234567890' }

  before do
    AuthorizationDefinition.reset!
    AuthorizationRequestForm.reset!
  end

  after do
    AuthorizationDefinition.reset!
    AuthorizationRequestForm.reset!
  end

  describe '#perform on approve' do
    it_behaves_like 'organization creation in hubee on approve'

    it 'creates a subscription linked to DataPass ID and CNOUS process code' do
      expect(hubee_api_client).to receive(:create_subscription).with(
        hash_including(
          datapassId: authorization_request.id,
          processCode: 'ProactiviteCnousBoursiers'
        )
      )

      perform
    end

    it 'sends the contact technique as the HubEE local administrator' do
      expect(hubee_api_client).to receive(:create_subscription).with(
        hash_including(
          localAdministrator: {
            email: 'jean.dupont.contact_technique@gouv.fr',
            firstName: 'Jean Contact technique',
            lastName: 'Dupont Contact technique',
            function: 'Agent Contact technique',
            phoneNumber: '0836656565',
          }
        )
      )

      perform
    end

    it 'stores the HubEE subscription id as external_provider_id' do
      perform

      expect(authorization_request.reload.external_provider_id).to eq(hubee_subscription_id)
    end

    context 'when HubEE raises AlreadyExistsError on a reopening' do
      let(:authorization_request) do
        create(:authorization_request, :reopened,
          type: habilitation_type.authorization_request_type,
          form_uid: habilitation_type.slug,
          organization:)
      end

      before do
        allow(hubee_api_client).to receive(:create_subscription).and_raise(HubEEAPIClient::AlreadyExistsError)
      end

      it 'does not raise an error' do
        expect { perform }.not_to raise_error
      end
    end
  end
end
