RSpec.describe EntityEligibility::Rules::APIEntreprise::MarchesPublics do
  def verdict_for(categorie_juridique)
    organization = build(:organization,
      legal_entity_registry: 'insee_sirene',
      legal_entity_id: '12345678900010',
      insee_payload: {
        'etablissement' => {
          'uniteLegale' => { 'categorieJuridiqueUniteLegale' => categorie_juridique },
        },
      })

    EntityEligibility::Engine.new(
      organization:,
      authorization_request_form: AuthorizationRequestForm.find('api-entreprise-marches-publics'),
    ).verdict
  end

  it 'is eligible for an administration' do
    expect(verdict_for('7210')).to be_eligible
    expect(verdict_for('7210').reason).to eq(:administration)
  end

  it 'is likely_eligible for an organisation with a public service mission' do
    expect(verdict_for('4110')).to be_likely_eligible
    expect(verdict_for('4110').reason).to eq(:public_commercial)
  end

  it 'is ineligible otherwise' do
    expect(verdict_for('5710')).to be_ineligible
    expect(verdict_for('5710').reason).to eq(:not_administration)
  end
end
