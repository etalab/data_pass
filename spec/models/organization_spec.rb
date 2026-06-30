RSpec.describe Organization do
  it 'has valid factories' do
    expect(build(:organization, siret: '21920023500014')).to be_valid
    expect(build(:organization, identity_federator: 'proconnect')).to be_valid
  end

  describe '#name' do
    subject { organization.name }

    context 'when organization is foreign' do
      let(:organization) { build(:organization, :foreign) }

      it { is_expected.to eq("L'organisation #{organization.legal_entity_id} (issu de isni)") }
    end

    context 'when insee_payload is blank' do
      let(:organization) { build(:organization, siret: '41040946000756') }

      it { is_expected.to eq("l'organisation #{organization.legal_entity_id} (nom inconnu)") }
    end

    context 'when organization is a personne physique' do
      let(:organization) do
        build(:organization,
          legal_entity_registry: 'insee_sirene',
          legal_entity_id: '12345678900010',
          insee_payload: {
            'etablissement' => {
              'uniteLegale' => {
                'categorieJuridiqueUniteLegale' => '1000',
                'nomUniteLegale' => 'DUPONT',
                'prenom1UniteLegale' => 'Jean'
              }
            }
          })
      end

      it { is_expected.to eq('DUPONT Jean') }
    end

    context 'when organization is a personne morale' do
      let(:organization) { build(:organization, siret: '21920023500014') }

      it { is_expected.to eq('COMMUNE DE CLAMART') }
    end
  end

  describe '#closed?' do
    subject { organization }

    context 'with open etablissement' do
      let(:organization) { build(:organization, siret: '21920023500014') }

      it { is_expected.not_to be_closed }
    end

    context 'with closed etablissement' do
      let(:organization) { build(:organization, siret: '21920023500022') }

      it { is_expected.to be_closed }
    end

    context 'with organization without insee payload' do
      let(:organization) { build(:organization, siret: '41040946000756') }

      it { is_expected.not_to be_closed }
    end
  end

  describe '#code_commune_etablissement' do
    subject { organization.code_commune_etablissement }

    context 'when the etablissement has an address' do
      let(:organization) do
        build(:organization,
          legal_entity_registry: 'insee_sirene',
          legal_entity_id: '12345678900010',
          insee_payload: {
            'etablissement' => {
              'adresseEtablissement' => { 'codeCommuneEtablissement' => '69123' },
            },
          })
      end

      it { is_expected.to eq('69123') }
    end

    context 'when insee_payload is blank' do
      let(:organization) { build(:organization, siret: '41040946000756') }

      it { is_expected.to be_nil }
    end
  end

  describe '#legal_category' do
    subject { organization.legal_category }

    let(:organization) do
      build(:organization,
        legal_entity_registry: 'insee_sirene',
        legal_entity_id: '12345678900010',
        insee_payload: {
          'etablissement' => {
            'uniteLegale' => unite_legale,
          },
        })
    end

    context 'when categorieJuridiqueUniteLegale is 7210 (commune)' do
      let(:unite_legale) { { 'categorieJuridiqueUniteLegale' => '7210' } }

      it { is_expected.to eq(:commune) }
    end

    context 'when categorieJuridiqueUniteLegale is 7220 (département)' do
      let(:unite_legale) { { 'categorieJuridiqueUniteLegale' => '7220' } }

      it { is_expected.to eq(:dept) }
    end

    context 'when categorieJuridiqueUniteLegale is 7230 (région)' do
      let(:unite_legale) { { 'categorieJuridiqueUniteLegale' => '7230' } }

      it { is_expected.to eq(:region) }
    end

    context 'when categorieJuridiqueUniteLegale is 7346 (EPCI, communauté de communes)' do
      let(:unite_legale) { { 'categorieJuridiqueUniteLegale' => '7346' } }

      it { is_expected.to eq(:other) }
    end

    context 'when categorieJuridiqueUniteLegale is absent from uniteLegale' do
      let(:unite_legale) { { 'denominationUniteLegale' => 'ACME' } }

      it { is_expected.to eq(:other) }
    end

    context 'when insee_payload is blank' do
      let(:organization) { build(:organization, siret: '41040946000756') }

      it { is_expected.to eq(:other) }
    end
  end

  describe '#activite_principale' do
    subject { organization.activite_principale }

    context 'when uniteLegale carries an activitePrincipale' do
      let(:organization) do
        build(:organization,
          legal_entity_registry: 'insee_sirene',
          legal_entity_id: '12345678900010',
          insee_payload: {
            'etablissement' => {
              'uniteLegale' => { 'activitePrincipaleUniteLegale' => '43.32A' },
            },
          })
      end

      it { is_expected.to eq('43.32A') }
    end

    context 'when insee_payload is blank' do
      let(:organization) { build(:organization, siret: '41040946000756') }

      it { is_expected.to be_nil }
    end
  end

  describe '#categorie_juridique' do
    subject { organization.categorie_juridique }

    context 'when uniteLegale carries a categorieJuridique' do
      let(:organization) do
        build(:organization,
          legal_entity_registry: 'insee_sirene',
          legal_entity_id: '12345678900010',
          insee_payload: {
            'etablissement' => {
              'uniteLegale' => { 'categorieJuridiqueUniteLegale' => '7210' },
            },
          })
      end

      it { is_expected.to eq('7210') }
    end

    context 'when insee_payload is blank' do
      let(:organization) { build(:organization, siret: '41040946000756') }

      it { is_expected.to be_nil }
    end
  end
end
