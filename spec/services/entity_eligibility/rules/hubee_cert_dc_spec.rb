RSpec.describe EntityEligibility::Rules::HubEECertDC do
  subject(:verdict) { described_class.new(engine).verdict }

  let(:engine) do
    EntityEligibility::Engine.new(
      organization:,
      authorization_request_form: AuthorizationRequestForm.find('hubee-cert-dc'),
    )
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

  context 'when the organization is a commune' do
    let(:categorie) { '7210' }

    it 'is eligible' do
      expect(verdict).to be_eligible
      expect(verdict.reason).to eq(:commune)
    end
  end

  context 'when the organization is another collectivité' do
    let(:categorie) { '7220' }

    it 'is ineligible' do
      expect(verdict).to be_ineligible
      expect(verdict.reason).to eq(:not_a_commune)
    end
  end

  context 'when the organization is a private entity' do
    let(:categorie) { '5710' }

    it 'is ineligible' do
      expect(verdict).to be_ineligible
    end
  end
end
