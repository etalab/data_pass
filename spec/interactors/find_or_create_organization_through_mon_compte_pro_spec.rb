RSpec.describe FindOrCreateOrganizationThroughMonComptePro do
  describe '#call' do
    subject(:find_or_create_user) { described_class.call(mon_compte_pro_omniauth_payload:) }

    let(:mon_compte_pro_omniauth_payload) { build(:mon_compte_pro_omniauth_payload) }

    it { is_expected.to be_a_success }

    context 'when the organization does not exist' do
      it 'creates a new organization' do
        expect { find_or_create_user }.to change(Organization, :count).by(1)
      end

      it 'assigns the organization payload from MonComptePro and updates last update' do
        find_or_create_user

        organization = Organization.last

        expect(organization.siret).to eq(mon_compte_pro_omniauth_payload['info']['siret'])
        expect(organization.mon_compte_pro_payload).to be_present
        expect(organization.last_mon_compte_pro_updated_at).to be_within(1.second).of(DateTime.now)
      end

      it 'returns the organization' do
        expect(find_or_create_user.organization).to be_a(Organization)
      end
    end
  end
end
