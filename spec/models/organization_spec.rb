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
end
