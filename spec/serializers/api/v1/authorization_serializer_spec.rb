RSpec.describe API::V1::AuthorizationSerializer, type: :serializer do
  describe '#serializable_hash' do
    subject(:serializable_hash) { serializer.serializable_hash }

    let(:serializer) { described_class.new(authorization) }
    let(:authorization) { create(:authorization) }

    it 'includes the authorization attributes' do
      expect(serializable_hash).to include(
        id: authorization.id,
        slug: authorization.slug,
        form_uid: authorization.form_uid,
        revoked: authorization.revoked,
        state: authorization.state,
        created_at: authorization.created_at,
        data: authorization.data,
      )
    end
  end
end
