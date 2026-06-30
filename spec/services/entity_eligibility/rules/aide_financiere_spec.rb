RSpec.describe EntityEligibility::Rules::AideFinanciere do
  subject(:verdict) { described_class.new(engine).verdict }

  let(:engine) do
    EntityEligibility::Engine.new(organization:, authorization_request_form: nil)
  end

  let(:organization) do
    build(:organization,
      legal_entity_registry: 'insee_sirene',
      legal_entity_id: '12345678900010',
      insee_payload: {
        'etablissement' => {
          'uniteLegale' => { 'categorieJuridiqueUniteLegale' => categorie },
        },
      })
  end

  context 'when the organization is an administration (7210, commune)' do
    let(:categorie) { '7210' }

    it 'is eligible' do
      expect(verdict).to be_eligible
      expect(verdict.reason).to eq(:administration)
    end
  end

  context 'when the organization is in the gray zone (4120, EPIC)' do
    let(:categorie) { '4120' }

    it 'is likely eligible' do
      expect(verdict).to be_likely_eligible
      expect(verdict.reason).to eq(:public_commercial)
    end
  end

  context 'when the organization is a private company (5710, SA)' do
    let(:categorie) { '5710' }

    it 'is ineligible' do
      expect(verdict).to be_ineligible
      expect(verdict.reason).to eq(:not_administration)
    end
  end
end
