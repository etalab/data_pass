RSpec.describe EligibilityRuleDecorator, type: :decorator do
  let(:eligibility_rule) do
    EligibilityRule.find_by(definition_id: 'api_particulier')
  end

  let(:decorator) { eligibility_rule.decorate }

  describe '#options' do
    it 'returns an array of decorated EligibilityOptions' do
      expect(decorator.options).to be_an(Array)
      expect(decorator.options).to all(be_a(EligibilityOptionDecorator))
    end

    it 'returns the correct number of options' do
      expect(decorator.options.size).to eq(3)
    end

    it 'each option is decorated and functional' do
      decorator.options.each do |option|
        expect(option.id).to be_present
        expect(option.outcome_id).to be_present
        expect(option.label).to be_present
      end
    end
  end

  describe '#request_access_path' do
    it 'returns the correct path for the API' do
      expected_path = '/demandes/api_particulier/nouveau?eligibility_confirmed=true'
      expect(decorator.request_access_path).to eq(expected_path)
    end
  end

  describe 'delegation' do
    it 'delegates unknown methods to the wrapped eligibility rule' do
      expect(decorator.definition_id).to eq('api_particulier')
      expect(decorator.id).to eq(eligibility_rule.id)
    end
  end
end
