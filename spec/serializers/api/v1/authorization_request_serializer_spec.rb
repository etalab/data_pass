RSpec.describe API::V1::AuthorizationRequestSerializer, type: :serializer do
  describe '#serializable_hash' do
    subject(:serializable_hash) { serializer.serializable_hash }

    let(:serializer) { described_class.new(authorization_request) }
    let(:authorization_request) { create(:authorization_request, :api_entreprise_mgdis, :validated) }

    it 'includes the authorization request attributes' do
      expect(serializable_hash).to include(
        id: authorization_request.id,
        public_id: authorization_request.public_id,
        type: authorization_request.type,
        state: authorization_request.state,
        form_uid: authorization_request.form_uid,
        created_at: authorization_request.created_at,
        updated_at: authorization_request.updated_at,
        last_submitted_at: authorization_request.last_submitted_at,
        last_validated_at: authorization_request.last_validated_at,
        reopening: authorization_request.reopening,
        reopened_at: authorization_request.reopened_at,
        data: authorization_request.data,
      )
    end

    it 'includes the organization' do
      expect(serializable_hash).to have_key(:organisation)
      expect(serializable_hash[:organisation]).to include(
        id: authorization_request.organization.id,
        siret: authorization_request.organization.siret,
        insee_payload: authorization_request.organization.insee_payload
      )
    end
  end
end
