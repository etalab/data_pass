RSpec.describe 'EntityEligibility API Particulier rules' do
  def verdict_for(form_uid, categorie_juridique:, naf: nil)
    unite_legale = { 'categorieJuridiqueUniteLegale' => categorie_juridique }
    unite_legale['activitePrincipaleUniteLegale'] = naf if naf

    organization = build(:organization,
      legal_entity_registry: 'insee_sirene',
      legal_entity_id: '12345678900010',
      insee_payload: { 'etablissement' => { 'uniteLegale' => unite_legale } })

    EntityEligibility::Engine.new(
      organization:,
      authorization_request_form: AuthorizationRequestForm.find(form_uid),
    ).verdict
  end

  describe 'CCAS' do
    it 'is likely_eligible for a CCAS, CIAS or any bloc communal entity' do
      expect(verdict_for('api-particulier-aides-sociales-ccas', categorie_juridique: '7361')).to be_likely_eligible
      expect(verdict_for('api-particulier-aides-sociales-ccas', categorie_juridique: '7367')).to be_likely_eligible
      expect(verdict_for('api-particulier-aides-sociales-ccas', categorie_juridique: '7210')).to be_likely_eligible
      expect(verdict_for('api-particulier-aides-sociales-ccas', categorie_juridique: '7346')).to be_likely_eligible
      expect(verdict_for('api-particulier-aides-sociales-ccas', categorie_juridique: '7348')).to be_likely_eligible
      expect(verdict_for('api-particulier-aides-sociales-ccas', categorie_juridique: '7343')).to be_likely_eligible
      expect(verdict_for('api-particulier-aides-sociales-ccas', categorie_juridique: '7344')).to be_likely_eligible
    end

    it 'is ineligible otherwise' do
      expect(verdict_for('api-particulier-aides-sociales-ccas', categorie_juridique: '7220')).to be_ineligible
    end
  end

  describe 'PSU (tarification EAJE)' do
    it 'is eligible for a bloc communal org or a crèche' do
      expect(verdict_for('api-particulier-tarification-eaje', categorie_juridique: '7210')).to be_eligible
      expect(verdict_for('api-particulier-tarification-eaje', categorie_juridique: '5710', naf: '88.91A')).to be_eligible
    end

    it 'is likely_eligible for an association' do
      expect(verdict_for('api-particulier-tarification-eaje', categorie_juridique: '9220')).to be_likely_eligible
    end

    it 'is ineligible otherwise' do
      expect(verdict_for('api-particulier-tarification-eaje', categorie_juridique: '5710')).to be_ineligible
    end
  end

  describe 'tarification municipale enfance' do
    it 'is likely_eligible for a bloc communal org or an association' do
      expect(verdict_for('api-particulier-tarification-municipale-enfance', categorie_juridique: '7346')).to be_likely_eligible
      expect(verdict_for('api-particulier-tarification-municipale-enfance', categorie_juridique: '9220')).to be_likely_eligible
    end

    it 'is unknown otherwise (no refusal defined)' do
      expect(verdict_for('api-particulier-tarification-municipale-enfance', categorie_juridique: '5710')).to be_unknown
    end
  end

  describe 'stationnement résidentiel' do
    it 'is likely_eligible for a bloc communal org' do
      expect(verdict_for('api-particulier-stationnement-residentiel', categorie_juridique: '7348')).to be_likely_eligible
    end

    it 'is ineligible otherwise' do
      expect(verdict_for('api-particulier-stationnement-residentiel', categorie_juridique: '5710')).to be_ineligible
    end
  end

  describe 'aides facultatives (form-specific)' do
    it 'requires a région on the régionale form' do
      expect(verdict_for('api-particulier-aides-facultatives-regionales', categorie_juridique: '7230')).to be_likely_eligible
      expect(verdict_for('api-particulier-aides-facultatives-regionales', categorie_juridique: '7220')).to be_ineligible
    end

    it 'requires a département on the départementale form' do
      expect(verdict_for('api-particulier-aides-facultatives-departementales', categorie_juridique: '7220')).to be_likely_eligible
      expect(verdict_for('api-particulier-aides-facultatives-departementales', categorie_juridique: '7230')).to be_ineligible
    end
  end

  describe 'cantines collèges/lycées (form-specific)' do
    it 'requires a région on the lycées form' do
      expect(verdict_for('api-particulier-tarification-cantines-lycees', categorie_juridique: '7230')).to be_likely_eligible
      expect(verdict_for('api-particulier-tarification-cantines-lycees', categorie_juridique: '7220')).to be_ineligible
    end

    it 'requires a département on the collèges form' do
      expect(verdict_for('api-particulier-tarification-cantines-colleges', categorie_juridique: '7220')).to be_likely_eligible
      expect(verdict_for('api-particulier-tarification-cantines-colleges', categorie_juridique: '7230')).to be_ineligible
    end
  end
end
