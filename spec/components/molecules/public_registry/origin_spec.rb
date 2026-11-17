RSpec.describe Molecules::PublicRegistry::Origin do
  describe '.normalize' do
    it 'reads the comma separated value of the address' do
      expect(described_class.normalize('portefeuille-europeen,datapass')).to eq(%w[datapass portefeuille-europeen])
    end

    it 'keeps known values in a stable order from a list' do
      expect(described_class.normalize(%w[portefeuille-europeen datapass datapass])).to eq(%w[datapass portefeuille-europeen])
    end

    it 'drops unknown and empty values' do
      expect(described_class.normalize('wallet,,datapass')).to eq(%w[datapass])
      expect(described_class.normalize(nil)).to eq([])
    end
  end

  it 'refuses an unknown origin' do
    expect { described_class.new('wallet') }.to raise_error(ArgumentError, /origin must be one of/)
  end
end
