RSpec.describe EligibilityRule do
  describe '#options' do
    it 'returns an array of EligibilityOption objects' do
      rule = described_class.find_by(definition_id: 'api_particulier')

      expect(rule.options).to be_an(Array)
      expect(rule.options).to all(be_a(EligibilityOption))
      expect(rule.options.size).to eq(4)
    end
  end

  describe 'rules of db/data/eligibility_rules.yml' do
    let(:options) { described_class.all.flat_map(&:options) }

    it 'gives each option a known result and a pictogram' do
      expect(options.map(&:eligible)).to all(be_in(%w[yes no maybe]))
      expect(options.map(&:type).uniq).to all(satisfy { |type| I18n.exists?("eligibility.pictograms.#{type}") })
    end

    it 'does not repeat an option type within a rule' do
      described_class.all.each do |rule|
        types = rule.options.map(&:type)

        expect(types).to eq(types.uniq), "#{rule.definition_id} répète un type de réponse"
      end
    end
  end
end
