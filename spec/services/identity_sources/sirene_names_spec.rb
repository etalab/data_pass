RSpec.describe IdentitySources::SireneNames do
  subject(:sirene_names) { described_class.new(organization) }

  let(:organization) { build(:organization, insee_payload:) }
  let(:insee_payload) do
    {
      'etablissement' => {
        'uniteLegale' => {
          'denominationUniteLegale' => 'COMMUNE DE VAL-EXEMPLE',
          'sigleUniteLegale' => 'VAL-EXEMPLE',
          'denominationUsuelle1UniteLegale' => 'Ville de Val-Exemple',
        },
        'periodesEtablissement' => [
          { 'dateFin' => nil, 'enseigne1Etablissement' => 'MAIRIE', 'denominationUsuelleEtablissement' => nil },
          { 'dateFin' => '2007-12-31', 'enseigne1Etablissement' => 'HÔTEL DE VILLE' },
        ],
      },
    }
  end

  describe '#kind_of' do
    it 'recognizes the denomination' do
      expect(sirene_names.kind_of('Commune de Val-Exemple')).to eq(:denomination)
    end

    it 'recognizes the sigle, ignoring case, accents, spaces and punctuation' do
      expect(sirene_names.kind_of('Val Exemple')).to eq(:sigle)
    end

    it 'recognizes a usual name' do
      expect(sirene_names.kind_of('ville de val-exemple')).to eq(:usual_name)
    end

    it 'recognizes the current enseigne of the establishment' do
      expect(sirene_names.kind_of('Mairie')).to eq(:enseigne)
    end

    it 'ignores the enseigne of a closed period' do
      expect(sirene_names.kind_of('Hôtel de ville')).to be_nil
    end

    it 'does not match a name that only contains a Sirene name' do
      expect(sirene_names.kind_of('Portail famille de Val-Exemple')).to be_nil
    end

    it 'does not match a blank name' do
      expect(sirene_names.kind_of(' - ')).to be_nil
    end

    context 'when the organization has no INSEE payload' do
      let(:insee_payload) { nil }

      it { expect(sirene_names.kind_of('Mairie')).to be_nil }
    end
  end

  describe '.normalize' do
    it 'keeps only unaccented lowercase letters and digits' do
      expect(described_class.normalize('Œuvre d’Été - 2026')).to eq('oeuvredete2026')
    end
  end
end
