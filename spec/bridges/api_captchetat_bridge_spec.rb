RSpec.describe APICaptchEtatBridge, type: :bridge do
  let(:authorization_request) { create(:authorization_request, :api_captchetat) }
  let(:external_provider_id) { SecureRandom.uuid }
  let(:create_subscription_piste_payload) do
    {
      'approval_id' => authorization_request.id,
      'status' => 'success',
      'user_created' => 'true',
      'application_created' => 'true',
      'granted_user' => authorization_request.contact_technique_email,
      'granted_prd_application' => "APP_DATAPASS_#{authorization_request.id}_#{authorization_request.contact_technique_email}",
      'granted_sbx_application' => "APP_DATAPASS_SBX_#{authorization_request.id}_#{authorization_request.contact_technique_email}",
      'granted_api' => 'CaptchEtat v2',
      'piste_api_link' => 'https://rec.piste.gouv.fr/api-center?filter=CaptchEtat%20v2',
      'piste_app_prd_link' => "https://rec.piste.gouv.fr/apps/application/view/#{external_provider_id}",
      'piste_app_sbx_link' => 'https =>//rec.piste.gouv.fr/apps/application/view/c3b988fc-6fb6-4ce0-aa5a-68d831403e6c?api-manager=2'
    }
  end

  describe '#on_approve' do
    subject(:trigger_bridge) { described_class.new.perform(authorization_request, 'approve') }

    before do
      allow_any_instance_of(PISTEAPIClient).to receive(:create_subscription).and_return(create_subscription_piste_payload) # rubocop:disable RSpec/AnyInstance
    end

    it 'affects external_provider_id to authorization request' do
      expect {
        trigger_bridge
      }.to change { authorization_request.reload.external_provider_id }.from(nil).to(external_provider_id)
    end
  end
end
