RSpec.describe NewAuthorizationRequest::APIEntrepriseFacade do
  subject(:facade) { described_class.new(authorization_definition:) }

  let(:authorization_definition) { instance_double(AuthorizationDefinition, editors: [editor]) }
  let(:an_already_integrated_editor) { an_object_having_attributes(already_integrated: ['api_entreprise']) }
  let(:editor) { Editor.all.first }

  it_behaves_like 'new authorization request facade'

  describe '#already_integrated_editors' do
    subject(:already_integrated_editors) { facade.already_integrated_editors }

    it { is_expected.to a_collection_including(an_already_integrated_editor) }
  end

  describe '#already_integrated_editors_ids' do
    subject(:already_integrated_editors_ids) { facade.already_integrated_editors_ids }

    let(:expected_editors_ids) { described_class::ALREADY_INTEGRATED_EDITORS }

    it { is_expected.to eq expected_editors_ids }
  end

  describe '#decorated_editors_ids' do
    subject(:decorated_editors_ids) { facade.decorated_editors_ids }

    let(:expected_editors_ids) { [editor.id, *described_class::ALREADY_INTEGRATED_EDITORS] }

    it { is_expected.to include(*expected_editors_ids) }
  end

  describe '#editors' do
    subject(:editors) { facade.editors }

    it { is_expected.to include(editor, an_already_integrated_editor) }
  end
end
