RSpec.describe EligibilityRule do
  describe '#options' do
    it 'returns an array of EligibilityOption objects' do
      rule = described_class.find_by(definition_id: 'api_particulier')

      expect(rule.options).to be_an(Array)
      expect(rule.options).to all(be_a(EligibilityOption))
      expect(rule.options.size).to eq(3)
    end
  end
end
