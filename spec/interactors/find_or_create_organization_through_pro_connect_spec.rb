RSpec.describe FindOrCreateOrganizationThroughProConnect do
  describe '#call' do
    subject(:find_or_create_organization) { described_class.call(pro_connect_omniauth_payload:) }

    let(:pro_connect_omniauth_payload) { build(:proconnect_omniauth_payload) }

    it { is_expected.to be_a_success }

    context 'when the organization does not exist' do
      it 'creates a new organization' do
        expect { find_or_create_organization }.to change(Organization, :count).by(1)
      end

      it 'returns the organization' do
        expect(find_or_create_organization.organization).to be_a(Organization)
      end

      it 'assigns the organization attributes' do
        organization = find_or_create_organization.organization

        expect(organization.legal_entity_id).to eq(pro_connect_omniauth_payload.dig('extra', 'raw_info', 'siret'))
        expect(organization.proconnect_payload).to be_present
        expect(organization.last_proconnect_updated_at).to be_present
      end
    end

    context 'when organization already exists' do
      let!(:organization) { create(:organization, legal_entity_id: pro_connect_omniauth_payload.dig('extra', 'raw_info', 'siret')) }

      it 'does not create a new organization' do
        expect { find_or_create_organization }.not_to change(Organization, :count)
      end

      it 'returns the organization' do
        expect(find_or_create_organization.organization).to eq(organization)
      end

      it 'updates ProConnect attributes' do
        find_or_create_organization

        organization.reload
        expect(organization.proconnect_payload).to be_present
        expect(organization.last_proconnect_updated_at).to be_present
      end
    end
  end
end
