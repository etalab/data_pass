RSpec.describe WalletRegistry::ImportRulebook do
  let(:payload) do
    {
      'source' => 'national',
      'identifier' => 'carte_etudiant',
      'version' => '1',
      'name' => 'Carte d’étudiant',
      'keywords' => 'étudiant',
      'provisional' => true,
      'source_details' => { 'method' => 'manual' },
      'formats' => [{ 'format' => 'dc+sd-jwt', 'vct' => 'urn:fr:etudiant:1' }],
      'claims' => [
        { 'identifier' => 'family_name', 'label' => 'Nom', 'requirement' => 'mandatory', 'group_name' => 'Identité', 'position' => 1, 'paths' => { 'dc+sd-jwt' => ['family_name'] } }
      ]
    }
  end

  it 'creates the rulebook, its formats, its data and their paths' do
    rulebook = described_class.call(payload)

    expect(rulebook.formats.map(&:meta)).to eq([{ 'vct_values' => ['urn:fr:etudiant:1'] }])
    expect(rulebook.claims.first.path_for(rulebook.formats.first)).to eq(['family_name'])
    expect(rulebook.search_text).to eq('carte d etudiant etudiant nom')
  end

  it 'can be run again without duplicating anything' do
    described_class.call(payload)

    expect { described_class.call(payload.merge('name' => 'Carte étudiante')) }.not_to change(WalletRegistry::RulebookClaimPath, :count)
    expect(WalletRegistry::Rulebook.where(identifier: 'carte_etudiant').pluck(:name)).to eq(['Carte étudiante'])
  end

  it 'retires the previous versions of the same rulebook without deleting them' do
    first = described_class.call(payload)
    second = described_class.call(payload.merge('version' => '2'))

    expect(first.reload).to be_retired
    expect(second).not_to be_retired
    expect(WalletRegistry::Rulebook.available.where(identifier: 'carte_etudiant')).to eq([second])
  end

  it 'leaves the same identifier of another source alone' do
    other = described_class.call(payload.merge('source' => 'custom'))
    described_class.call(payload.merge('version' => '2'))

    expect(other.reload).not_to be_retired
  end
end
