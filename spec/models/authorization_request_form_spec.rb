RSpec.describe AuthorizationRequestForm do
  describe '.all' do
    it 'returns a list of all authorizations forms' do
      expect(described_class.all).to be_all { |a| a.is_a? AuthorizationRequestForm }
    end
  end
end
