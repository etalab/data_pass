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

    it 'gives each option a known result and an existing pictogram' do
      expect(options.map(&:eligible)).to all(be_in(%w[yes no maybe]))

      options.map(&:type).uniq.each do |type|
        pictogram = I18n.t("eligibility.pictograms.#{type}", default: nil)

        expect(pictogram).to be_present, "#{type} n’a pas de pictogramme dans eligibility.pictograms"
        expect(Rails.application.assets.resolver.resolve("artwork/pictograms/#{pictogram}.svg")).to be_present, "#{pictogram}.svg introuvable"
      end
    end

    it 'does not repeat an option type within a rule' do
      described_class.all.each do |rule|
        types = rule.options.map(&:type)

        expect(types).to eq(types.uniq), "#{rule.definition_id} répète un type de réponse"
      end
    end
  end
end
