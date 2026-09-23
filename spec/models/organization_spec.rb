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

  describe 'INSEE payload freshness scopes' do
    let!(:organization_never_refreshed) { create(:organization, insee_payload: nil, last_insee_payload_updated_at: nil) }
    let!(:organization_with_empty_payload) { create(:organization, insee_payload: {}, last_insee_payload_updated_at: 42.days.ago) }
    let!(:stale_organization) { create(:organization, insee_payload: { 'etablissement' => {} }, last_insee_payload_updated_at: 42.days.ago) }
    let!(:fresh_organization) { create(:organization, insee_payload: { 'etablissement' => {} }, last_insee_payload_updated_at: 1.hour.ago) }

    before { create(:organization, :foreign, insee_payload: nil, last_insee_payload_updated_at: nil) }

    it 'lists the INSEE organizations without payload, whether null or empty' do
      expect(described_class.without_insee_payload).to contain_exactly(organization_never_refreshed, organization_with_empty_payload)
    end

    it 'lists the INSEE organizations never refreshed' do
      expect(described_class.never_insee_refreshed).to contain_exactly(organization_never_refreshed)
    end

    it 'lists the INSEE organizations whose payload is older than the freshness window' do
      expect(described_class.with_stale_insee_payload).to contain_exactly(organization_with_empty_payload, stale_organization)
    end

    it 'lists the INSEE organizations whose payload is within the freshness window' do
      expect(described_class.with_fresh_insee_payload).to contain_exactly(fresh_organization)
    end

    it 'lists the INSEE organizations needing a refresh, never refreshed first' do
      expect(described_class.needing_insee_refresh.first).to eq(organization_never_refreshed)
      expect(described_class.needing_insee_refresh).to contain_exactly(organization_never_refreshed, organization_with_empty_payload, stale_organization)
    end
  end

  describe 'organizations skipped for the INSEE calls' do
    let!(:skipped_by_siret) { create(:organization, last_insee_payload_updated_at: nil) }
    let!(:skipped_by_siren) { create(:organization, last_insee_payload_updated_at: nil) }
    let!(:not_skipped_organization) { create(:organization, last_insee_payload_updated_at: nil) }

    before do
      Setting.set(:insee_skipped_identifiers, [skipped_by_siret.siret, skipped_by_siren.siret.first(9)])
    end

    it 'skips an organization listed by its SIRET or by its SIREN' do
      expect([skipped_by_siret, skipped_by_siren, not_skipped_organization].map(&:insee_skipped?)).to eq([true, true, false])
    end

    it 'never skips a foreign organization' do
      expect(build(:organization, :foreign)).not_to be_insee_skipped
    end

    it 'lists the skipped organizations' do
      expect(described_class.insee_skipped).to contain_exactly(skipped_by_siret, skipped_by_siren)
    end

    it 'leaves the skipped organizations out of the refresh' do
      expect(described_class.needing_insee_refresh).to contain_exactly(not_skipped_organization)
    end
  end
end
