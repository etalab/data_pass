RSpec.describe DataProvider do
  describe '.all' do
    subject { described_class.all }

    it 'works' do
      expect(described_class.all).to be_all { |a| a.is_a? DataProvider }
    end
  end
end
