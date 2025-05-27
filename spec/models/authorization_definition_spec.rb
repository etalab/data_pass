RSpec.describe AuthorizationDefinition do
  describe '.all' do
    it 'returns a list of all authorizations definition' do
      expect(described_class.all).to be_all { |a| a.is_a? AuthorizationDefinition }
    end
  end

  describe '.where' do
    context 'when filtering by exact match' do
      it 'returns definitions that match the exact value with id attribute' do
        result = described_class.where(id: 'api_entreprise')
        expect(result.map(&:id)).to eq ['api_entreprise']
      end

      it 'returns definitions that match the provider with name attribute' do
        result = described_class.where(name: 'API Entreprise')
        expect(result.map(&:name)).to eq ['API Entreprise']
      end
    end

    context 'when filtering by array inclusion' do
      it 'returns definitions when the attribute value is included in the provided array' do
        definition_ids = %w[api_entreprise api_particulier]
        result = described_class.where(id: definition_ids)

        expect(result.map(&:id)).to match_array(definition_ids)
      end
    end

    context 'when filtering by authorization_request_class' do
      it 'returns definitions that match the authorization_request_class as a string for exact match' do
        result = described_class.where(authorization_request_class: 'AuthorizationRequest::APIEntreprise')
        expect(result.map(&:id)).to eq ['api_entreprise']
      end

      it 'returns definitions that match the authorization_request_class as a string for array inclusion' do
        result = described_class.where(authorization_request_class: %w[AuthorizationRequest::APIEntreprise AuthorizationRequest::APIImpotParticulier])
        expect(result.map(&:id)).to match_array(%w[api_entreprise api_impot_particulier])
      end
    end

    context 'when filtering by multiple criteria' do
      it 'returns definitions that match all criteria' do
        result = described_class.where(
          authorization_request_class: %w[AuthorizationRequest::APIImpotParticulier AuthorizationRequest::APIEntreprise], 
          id: 'api_impot_particulier'
        )
        expect(result.map(&:id)).to eq ['api_impot_particulier']
      end
    end

    context 'when filtering with empty parameters' do
      it 'returns all definitions when given empty hash' do
        result = described_class.where({})

        expect(result.map(&:id)).to match_array(described_class.all.map(&:id))
      end
    end

    context 'when filtering by non-existent attribute' do
      it 'raises an error when trying to access non-existent attribute' do
        expect {
          described_class.where(non_existent_attribute: 'value')
        }.to raise_error(NoMethodError)
      end
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
