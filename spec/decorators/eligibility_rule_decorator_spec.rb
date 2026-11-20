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
      expect(decorator.options.size).to eq(4)
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

    it 'keeps the same path for an option without use case' do
      collectivite_option = decorator.options.find { |option| option.type == 'collectivite_ou_administration' }

      expected_path = '/demandes/api_particulier/nouveau?eligibility_confirmed=true'
      expect(decorator.request_access_path(collectivite_option)).to eq(expected_path)
    end

    it 'adds the use case of the option to filter the forms' do
      eaje_option = decorator.options.find { |option| option.type == 'eaje' }

      expected_path = '/demandes/api_particulier/nouveau?eligibility_confirmed=true&use_case=tarification_eaje'
      expect(decorator.request_access_path(eaje_option)).to eq(expected_path)
    end
  end

  describe 'delegation' do
    it 'delegates unknown methods to the wrapped eligibility rule' do
      expect(decorator.definition_id).to eq('api_particulier')
      expect(decorator.id).to eq(eligibility_rule.id)
    end
  end

  context 'with a rule that defines its own button and lead' do
    let(:eligibility_rule) do
      EligibilityRule.new(
        definition_id: 'regle_de_test',
        request_access_label: 'Commencer l’enregistrement',
        options: [
          { 'type' => 'dirigeant', 'eligible' => 'yes', 'body' => 'Test', 'request_access_params' => { 'parcours' => 'dirigeant' } },
          { 'type' => 'association', 'eligible' => 'no', 'body' => 'Test' }
        ]
      )
    end

    around do |example|
      I18n.backend.store_translations(:fr, eligibility: { leads: { regle_de_test: 'Votre réponse détermine la façon de vous connecter.' } })
      example.run
    ensure
      I18n.backend.reload!
    end

    it 'uses the button label of the rule' do
      expect(decorator.request_access_label).to eq('Commencer l’enregistrement')
    end

    it 'adds the parameter of the option to the path' do
      dirigeant_option = decorator.options.find { |option| option.type == 'dirigeant' }

      expected_path = '/demandes/regle_de_test/nouveau?eligibility_confirmed=true&parcours=dirigeant'
      expect(decorator.request_access_path(dirigeant_option)).to eq(expected_path)
    end

    it 'keeps the parameters of the journey when the option tries to override them' do
      option = EligibilityOption.new(
        'type' => 'dirigeant', 'eligible' => 'yes', 'body' => 'Test', 'use_case' => 'cas_de_test',
        'request_access_params' => { 'eligibility_confirmed' => false, 'use_case' => 'autre_cas' }
      ).decorate

      expected_path = '/demandes/regle_de_test/nouveau?eligibility_confirmed=true&use_case=cas_de_test'
      expect(decorator.request_access_path(option)).to eq(expected_path)
    end

    it 'uses the lead of the rule' do
      expect(decorator.lead).to eq('Votre réponse détermine la façon de vous connecter.')
    end
  end

  describe '#lead' do
    let(:eligibility_rule) { EligibilityRule.new(definition_id: 'regle_sans_chapo', options: []) }

    it 'has no lead by default' do
      expect(decorator.lead).to be_nil
    end

    it 'has no title of its own by default' do
      expect(decorator.title).to be_nil
    end
  end

  context 'with the rule of the wallet registry' do
    let(:eligibility_rule) { EligibilityRule.find_by(definition_id: 'registre_wallet') }

    it 'gives the page the title of the registry' do
      expect(decorator.title).to eq('Enregistrer votre organisation au registre du portefeuille européen')
    end

    it 'sends each answer that can sign in to the start page with its answer' do
      paths = decorator.options.select(&:shows_request_access_button?).to_h { |option| [option.type, decorator.request_access_path(option)] }

      expect(paths).to eq(
        'dirigeant_entreprise' => '/demandes/registre_wallet/nouveau?eligibility_confirmed=true&parcours=dirigeant',
        'agent_public' => '/demandes/registre_wallet/nouveau?eligibility_confirmed=true&parcours=agent'
      )
    end

    it 'gives the association no way to sign in' do
      association = decorator.options.find { |option| option.type == 'association' }

      expect(association).not_to be_shows_request_access_button
      expect(association).not_to be_shows_custom_cta
    end
  end
end
