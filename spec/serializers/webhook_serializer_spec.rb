RSpec.describe WebhookSerializer, type: :serializer do
  describe '#serializable_hash' do
    subject(:serializable_hash) { webhook_serializer.serializable_hash }

    let(:webhook_serializer) { described_class.new(authorization_request, 'whatever') }
    let(:authorization_request) { create(:authorization_request, :api_entreprise, :validated) }

    it 'contains valid keys/values' do
      expect(serializable_hash).to include(
        event: 'whatever',
        fired_at: instance_of(Integer),
        model_type: 'authorization_request/api_entreprise',
        model_id: authorization_request.id,
        data: hash_including(
          id: authorization_request.id,
          state: authorization_request.state,
          form_uid: authorization_request.form_uid,
          organization: hash_including(
            siret: authorization_request.organization.siret,
          ),
          applicant: hash_including(
            email: authorization_request.applicant.email,
          ),
          data: hash_including(
            intitule: authorization_request.intitule,
            scopes: authorization_request.scopes,
          )
        )
      )
    end
  end
end
