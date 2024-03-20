RSpec.describe Subdomain do
  describe '.all' do
    it 'returns a list of all subdomains, each with at least one authorization definition' do
      expect(described_class.all).to be_all { |a| a.is_a? Subdomain }
      expect(described_class.all.map(&:authorization_definitions)).to be_all(&:present?)
    end
  end
end
