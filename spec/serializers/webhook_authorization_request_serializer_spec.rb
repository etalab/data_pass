RSpec.describe WebhookAuthorizationRequestSerializer, type: :serializer do
  describe '#serializable_hash' do
    subject(:serializable_hash) { serializer.serializable_hash }

    let(:serializer) { described_class.new(authorization_request) }
    let(:authorization_request) { create(:authorization_request, :api_entreprise_mgdis, :validated) }

    it 'includes the authorization request attributes' do
      expect(serializable_hash).to include(
        :data,
        :organization,
        :applicant,
        :service_provider,
        :authorizations,
        id: authorization_request.id,
        public_id: authorization_request.public_id,
        type: authorization_request.type,
        state: authorization_request.state,
        form_uid: authorization_request.form_uid,
        created_at: authorization_request.created_at,
        last_submitted_at: authorization_request.last_submitted_at,
        last_validated_at: authorization_request.last_validated_at,
      )
    end

    it 'includes the authorizations' do
      expect(serializable_hash).to have_key(:authorizations)
      expect(serializable_hash[:authorizations]).to be_an(Array)

      authorization_request.reload.authorizations.each do |authorization|
        authorization_hash = serializable_hash[:authorizations].find { |a| a[:id] == authorization.id }
        expect(authorization_hash).to include(
          id: authorization.id,
        )
      end
    end
  end
end
