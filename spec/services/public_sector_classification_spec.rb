RSpec.describe PublicSectorClassification do
  subject(:classification) { described_class.new(organization) }

  let(:organization) { build(:organization, siret:, insee_payload:) }
  let(:siret) { '41040946000756' }
  let(:legal_category) { '7210' }
  let(:administrative_state) { 'A' }
  let(:insee_payload) do
    {
      'etablissement' => {
        'uniteLegale' => {
          'categorieJuridiqueUniteLegale' => legal_category,
          'etatAdministratifUniteLegale' => administrative_state
        }
      }
    }
  end

  it 'classifies an active organization with a public legal category as public' do
    expect(classification).to have_attributes(known?: true, public?: true, private?: false, reason: :public_legal_category)
  end

  context 'with a private legal category' do
    let(:legal_category) { '5710' }

    it { is_expected.to have_attributes(public?: false, private?: true, reason: :private_legal_category) }

    context 'when the SIREN is whitelisted' do
      let(:siret) { '78452331800010' }

      it { is_expected.to have_attributes(public?: true, reason: :whitelisted_siren) }
    end
  end

  context 'without legal category' do
    let(:legal_category) { nil }

    it { is_expected.to have_attributes(known?: false, public?: false, private?: false, reason: :unknown_legal_category) }
  end

  context 'without INSEE data' do
    let(:insee_payload) { nil }

    it { is_expected.to have_attributes(known?: false, public?: false, private?: false) }
  end

  context 'when the organization is closed' do
    let(:administrative_state) { 'C' }

    it { is_expected.to have_attributes(private?: true, reason: :closed_unit) }

    context 'when the SIREN is whitelisted' do
      let(:siret) { '78452331800010' }

      it { is_expected.to have_attributes(private?: true, reason: :closed_unit) }
    end
  end

  context 'when the SIREN is blacklisted' do
    let(:legal_category) { '4110' }
    let(:siret) { '34867901000010' }

    it { is_expected.to have_attributes(private?: true, reason: :blacklisted_siren) }
  end

  context 'with other lists' do
    subject(:classification) { described_class.new(organization, lists:) }

    let(:lists) do
      PublicSectorLists.new(
        'source' => {},
        'legal_categories' => [],
        'whitelisted_sirens' => [],
        'blacklisted_sirens' => []
      )
    end

    it 'applies the rule to the given lists' do
      expect(classification).to have_attributes(private?: true, reason: :private_legal_category)
    end
  end

  context 'with the INSEE payload of an existing organization' do
    it 'classifies a commune as public' do
      expect(described_class.new(build(:organization, siret: '21920023500014'))).to be_public
    end

    it 'classifies a private company as private' do
      expect(described_class.new(build(:organization, siret: '32816124500027'))).to be_private
    end

    it 'classifies a closed public organization as private' do
      expect(described_class.new(build(:organization, siret: '13002437500011'))).to be_private
    end

    it 'does not know an organization without INSEE data' do
      expect(described_class.new(build(:organization, siret: '41040946000756'))).not_to be_known
    end
  end
end
