RSpec.describe INSEEPostalAddress do
  subject(:address) { described_class.new(address_payload).to_s }

  context 'with the address of a town hall' do
    let(:address_payload) { { 'numeroVoieEtablissement' => '1', 'typeVoieEtablissement' => 'PL', 'libelleVoieEtablissement' => 'MAURICE GUNSBOURG', 'codePostalEtablissement' => '92140', 'libelleCommuneEtablissement' => 'CLAMART' } }

    it { is_expected.to eq('1 place Maurice Gunsbourg, 92140 Clamart') }
  end

  context 'with small words and a compound town name' do
    let(:address_payload) { { 'numeroVoieEtablissement' => '12', 'typeVoieEtablissement' => 'RUE', 'libelleVoieEtablissement' => 'DE LA REPUBLIQUE', 'codePostalEtablissement' => '26000', 'libelleCommuneEtablissement' => 'VAL-EXEMPLE-SUR-RHONE' } }

    it { is_expected.to eq('12 rue de la Republique, 26000 Val-Exemple-sur-Rhone') }
  end

  context 'with an unknown street type and no number' do
    let(:address_payload) { { 'typeVoieEtablissement' => 'XYZ', 'libelleVoieEtablissement' => 'DES LILAS', 'codePostalEtablissement' => '69003', 'libelleCommuneEtablissement' => 'LYON' } }

    it { is_expected.to eq('xyz des Lilas, 69003 Lyon') }
  end

  context 'without address' do
    let(:address_payload) { nil }

    it { is_expected.to eq('') }
  end
end
