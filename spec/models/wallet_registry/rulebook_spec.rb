RSpec.describe WalletRegistry::Rulebook do
  let(:pid) { described_class.find_by!(identifier: 'pid') }
  let(:mdl) { described_class.find_by!(identifier: 'mdl') }

  def claims_of(rulebook, *identifiers)
    rulebook.claims.where(identifier: identifiers).order(:position)
  end

  it 'holds the PID and the mobile driving licence of the manual reading, marked as provisional' do
    expect(described_class.available.order(:id).map { |rulebook| [rulebook.identifier, rulebook.source, rulebook.provisional] }).to eq(
      [['pid', 'eu_catalog', true], ['mdl', 'eu_catalog', true]]
    )
    expect(pid.source_details).to include('method' => 'manual', 'commit' => '36f8adcf91', 'read_on' => '2026-11-17')
  end

  describe 'RulebookFormat#credential_for' do
    it 'gives one TS5 Credential per format of the PID' do
      claims = claims_of(pid, 'family_name', 'birth_date')

      expect(pid.formats.map { |format| format.credential_for(claims) }).to eq(
        [
          {
            'format' => 'dc+sd-jwt',
            'meta' => { 'vct_values' => ['urn:eudi:pid:1'] },
            'claims' => [{ 'path' => ['family_name'] }, { 'path' => ['birthdate'] }]
          },
          {
            'format' => 'mso_mdoc',
            'meta' => { 'doctype_value' => 'eu.europa.ec.eudi.pid.1' },
            'claims' => [{ 'path' => %w[eu.europa.ec.eudi.pid.1 family_name] }, { 'path' => %w[eu.europa.ec.eudi.pid.1 birth_date] }]
          }
        ]
      )
    end

    it 'leaves out of a format the data it does not encode' do
      sd_jwt, mdoc = pid.formats.map { |format| format.credential_for(claims_of(pid, 'resident_house_number')) }

      expect(sd_jwt['claims']).to eq([{ 'path' => %w[address house_number] }])
      expect(mdoc['claims']).to be_empty
    end

    it 'gives a single mdoc Credential for the driving licence' do
      expect(mdl.formats.map { |format| format.credential_for(claims_of(mdl, 'age_over_18')) }).to eq(
        [{ 'format' => 'mso_mdoc', 'meta' => { 'doctype_value' => 'org.iso.18013.5.1.mDL' }, 'claims' => [{ 'path' => %w[org.iso.18013.5.1 age_over_18] }] }]
      )
    end
  end

  it 'gives each data a path in every format of its rulebook, except the house number' do
    incomplete = described_class.available.flat_map do |rulebook|
      rulebook.claims.reject { |claim| claim.format_count == rulebook.formats.size }.map { |claim| "#{rulebook.identifier}.#{claim.identifier}" }
    end

    expect(incomplete).to eq(['pid.resident_house_number'])
  end

  describe '.search' do
    it 'ignores accents and case' do
      expect(described_class.available.search('PERMIS').map(&:identifier)).to eq(['mdl'])
      expect(described_class.available.search('identite').map(&:identifier)).to eq(['pid'])
    end

    it 'searches the labels of the data' do
      expect(described_class.available.search('catégories').map(&:identifier)).to eq(['mdl'])
    end

    it 'gives everything without a query' do
      expect(described_class.available.search('').count).to eq(2)
    end
  end
end
