RSpec.describe EntityEligibility::Rules::APIEntreprise do
  subject(:verdict) { described_class.new(engine).verdict }

  let(:engine) do
    EntityEligibility::Engine.new(
      organization:,
      authorization_request_form: AuthorizationRequestForm.find('api-entreprise-socle-de-base'),
    )
  end

  let(:organization) do
    build(:organization,
      legal_entity_registry: 'insee_sirene',
      legal_entity_id: '12345678900010',
      insee_payload: {
        'etablissement' => {
          'uniteLegale' => { 'activitePrincipaleUniteLegale' => naf_code },
        },
      })
  end

  context 'when the organization is a menuiserie' do
    let(:naf_code) { '43.32A' }

    it 'is ineligible' do
      expect(verdict).to be_ineligible
      expect(verdict.reason).to eq(:menuiserie)
    end
  end

  context 'when the organization runs another activity' do
    let(:naf_code) { '84.11Z' }

    it 'is unknown' do
      expect(verdict).to be_unknown
    end
  end
end
