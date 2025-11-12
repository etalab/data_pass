require 'rails_helper'

RSpec.describe EligibilityRule do
  describe '.find_by_definition_id' do
    it 'returns the rule for a valid definition_id' do
      rule = described_class.find_by(definition_id: 'api-particulier')

      expect(rule).to be_present
      expect(rule.definition_id).to eq('api-particulier')
    end

    it 'returns nil for an unknown definition_id' do
      rule = described_class.find_by(definition_id: 'unknown-api')

      expect(rule).to be_nil
    end
  end

  describe '#options' do
    it 'returns an array of options' do
      rule = described_class.find_by(definition_id: 'api-particulier')

      expect(rule.options).to be_an(Array)
      expect(rule.options.size).to eq(3)
    end

    it 'options have the correct structure' do
      rule = described_class.find_by(definition_id: 'api-particulier')
      option = rule.options.first

      expect(option).to have_key('type')
      expect(option).to have_key('eligible')
      expect(option).to have_key('body')
    end
  end
end
