RSpec.describe FindOrCreateOrganizationForAPI do
  describe '#call' do
    subject(:result) { described_class.call(siret: '13002526500013') }

    context 'when the organization does not exist' do
      it { is_expected.to be_a_success }

      it 'creates a new organization' do
        expect { result }.to change(Organization, :count).by(1)
      end

      it 'sets legal_entity_id and registry' do
        organization = result.organization

        expect(organization.legal_entity_id).to eq('13002526500013')
        expect(organization.legal_entity_registry).to eq('insee_sirene')
      end
    end

    context 'when the organization already exists' do
      let!(:existing_org) { create(:organization, legal_entity_id: '13002526500013', legal_entity_registry: 'insee_sirene') }

      it { is_expected.to be_a_success }

      it 'does not create a new organization' do
        expect { result }.not_to change(Organization, :count)
      end

      it 'returns the existing organization' do
        expect(result.organization).to eq(existing_org)
      end
    end

    context 'with an invalid siret' do
      subject(:result) { described_class.call(siret: 'invalid') }

      it { is_expected.to be_a_failure }

      it 'fails with organization_invalid and full messages' do
        expect(result.error[:key]).to eq(:organization_invalid)
        expect(result.error[:errors]).not_to be_empty
      end
    end
  end
end
