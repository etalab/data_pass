RSpec.describe FindOrCreateOrganization, type: :organizer do
  subject(:organizer) { described_class.call(organization_params:) }

  let(:siret) { generate(:siret) }

  context 'with valid params' do
    let(:organization_params) do
      {
        legal_entity_id: siret,
        legal_entity_registry: 'insee_sirene',
      }
    end

    context 'when organization does not exist' do
      context 'when siret exists in the INSEE Sirene API' do
        before do
          mock_insee_sirene_api_etablissement_valid(siret:)
        end

        it { is_expected.to be_success }

        it 'creates a new organization' do
          expect { organizer }.to change(Organization, :count).by(1)
        end

        it 'adds the organization INSEE payload synchronously' do
          organizer

          expect(Organization.last.insee_payload).to be_present
        end
      end

      context 'when siret does not exist in the INSEE Sirene API' do
        before do
          mock_insee_sirene_api_etablissement_not_found
        end

        it { is_expected.to be_failure }

        it 'returns an error related to INSEE not found error' do
          expect(organizer.error).to eq(:insee_entity_not_found)
        end

        it 'does not create an organization' do
          expect { organizer }.not_to change(Organization, :count)
        end
      end
    end

    context 'when organization already exists' do
      let!(:organization) { create(:organization, legal_entity_id: siret, legal_entity_registry: 'insee_sirene') }

      before do
        mock_insee_sirene_api_etablissement_valid(siret:)
      end

      it { is_expected.to be_success }

      it 'does not create a new organization' do
        expect {
          organizer
        }.not_to change(Organization, :count)
      end

      it 'updates the existing organization INSEE payload synchronously' do
        expect {
          organizer
        }.to change { organization.reload.insee_payload }
      end
    end
  end

  context 'with invalid params' do
    let(:organization_params) do
      {
        legal_entity_id: 'invalid_siret',
        legal_entity_registry: 'insee_sirene',
      }
    end

    it { is_expected.to be_failure }

    it 'returns an error related to invalid organization params' do
      expect(organizer.error).to eq(:invalid_organization_params)
    end

    it 'does not create an organization' do
      expect { organizer }.not_to change(Organization, :count)
    end
  end
end
