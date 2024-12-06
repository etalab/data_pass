require 'generator_spec'
require 'generators/multi_stages_definition/multi_stages_definition_generator'

RSpec.describe MultiStagesDefinitionGenerator, type: :generator do
  arguments ['FranceGenerateur', 'Generateur de France']

  before do
    import_for_generator('config/authorization_definitions.yml')
    import_for_generator('spec/factories/authorization_requests.rb')

    run_generator
  end

  describe 'sandbox model file' do
    subject { generator_file('app/models/authorization_request/france_generateur_sandbox.rb') }

    it { is_expected.to have_valid_syntax }
  end

  describe 'production model file' do
    subject { generator_file('app/models/authorization_request/france_generateur.rb') }

    it { is_expected.to have_valid_syntax }
  end

  describe 'definition YAML file' do
    subject(:file) { generator_file('config/authorization_definitions.yml') }

    it { expect(file.read).to include(/^  france_generateur_sandbox:/) }
    it { expect(file.read).to include(/^  france_generateur:/) }

    it 'is a valid YAML' do
      expect { YAML.load_file(subject, aliases: true) }.not_to raise_error
    end
  end

  describe 'forms YAML file' do
    subject(:file) { generator_file('config/authorization_request_forms/france_generateur.yml') }

    it { expect(file.read).to include(/^france-generateur-sandbox:/) }
    it { expect(file.read).to include(/^france-generateur:/) }

    it { expect(file.read).to include('authorization_request: FranceGenerateurSandbox') }
    it { expect(file.read).to include('authorization_request: FranceGenerateur') }

    it 'is a valid YAML' do
      expect { YAML.load_file(subject, aliases: true) }.not_to raise_error
    end
  end

  describe 'factory file' do
    subject(:file) { generator_file('spec/factories/authorization_requests.rb') }

    it { is_expected.to have_valid_syntax }

    it { expect(file.read).to include(/trait :france_generateur/) }
    it { expect(file.read).to include(/trait :france_generateur_sandbox/) }
  end

  describe 'feature test file' do
    subject(:file) { generator_file('features/habilitations/france_generateur.feature') }

    it { expect(file.present?).to be(true) }
  end
end
