RSpec.describe AuthorizationDefinition do
  describe '.all' do
    it 'returns a list of all authorizations definition' do
      expect(described_class.all).to be_all { |a| a.is_a? AuthorizationDefinition }
    end
  end

  describe '.available_forms' do
    subject(:available_forms) { instance.available_forms }

    let(:instance) { described_class.find('api_entreprise') }

    it 'returns a list of all forms' do
      expect(available_forms.count).to be > 0

      expect(available_forms).to be_all do |form|
        form.is_a?(AuthorizationRequestForm) &&
          form.authorization_request_class == AuthorizationRequest::APIEntreprise
      end
    end
  end

  describe '.editors' do
    subject(:editors) { instance.editors }

    let(:instance) { described_class.find('api_entreprise') }

    it 'returns a list of all editors' do
      expect(editors.count).to be > 0

      expect(editors).to be_all do |editor|
        editor.is_a?(Editor)
      end
    end
  end
end
