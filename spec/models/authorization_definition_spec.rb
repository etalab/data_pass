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

  describe '#support_email' do
    it 'is present on each definition' do
      described_class.all.each do |definition|
        expect(definition.support_email).to be_present, "#{definition.id} support email is missing"
      end
    end
  end

  describe '#editors' do
    subject(:editors) { instance.editors }

    let(:instance) { described_class.find('api_particulier') }

    it 'returns a list of all editors' do
      expect(editors.count).to be > 0

      expect(editors).to be_all do |editor|
        editor.is_a?(ServiceProvider) && editor.editor?
      end
    end

    it 'does not return duplicates' do
      expect(editors.map(&:id)).to eq(editors.map(&:id).uniq)
    end
  end

  describe '#instructors' do
    subject(:instructors) { instance.instructors }

    let(:instance) { described_class.find('api_entreprise') }

    let(:authorization_request) { create(:authorization_request, :api_entreprise) }

    let!(:valid_instructor) { create(:user, :instructor, authorization_request_types: %i[api_entreprise]) }
    let!(:valid_instructor_with_multiple_authorization_type) { create(:user, :instructor, authorization_request_types: %i[api_entreprise api_particulier]) }
    let!(:invalid_instructor) { create(:user, :instructor, authorization_request_types: %i[api_particulier]) }

    it { is_expected.to contain_exactly(valid_instructor, valid_instructor_with_multiple_authorization_type) }
  end

  describe '#next_stage_definition' do
    subject(:next_stage_definition) { instance.next_stage_definition }

    context 'when definition has no stage' do
      let(:instance) { described_class.find('api_entreprise') }

      it { is_expected.to be_nil }
    end

    context 'when definition has stages' do
      let(:instance) { described_class.find('api_impot_particulier_sandbox') }

      it { expect(next_stage_definition.id).to eq('api_impot_particulier') }
    end
  end
end
