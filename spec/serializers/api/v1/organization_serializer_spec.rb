RSpec.describe API::V1::OrganizationSerializer, type: :serializer do
  describe '#serializable_hash' do
    subject(:serializable_hash) { serializer.serializable_hash }

    let(:serializer) { described_class.new(organization) }
    let(:organization) { create(:organization) }

    it 'includes the organization attributes' do
      expect(serializable_hash).to include(
        id: organization.id,
        siret: organization.siret,
        raison_sociale: organization.raison_sociale,
        insee_payload: organization.insee_payload
      )
    end
  end
end
