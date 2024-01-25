RSpec.describe Editor do
  describe '.all' do
    it 'returns a list of all editors' do
      expect(described_class.all).to be_all { |a| a.is_a? Editor }
    end
  end
end
