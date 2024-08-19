RSpec.describe NewAuthorizationRequest::DefaultFacade do
  subject(:facade) { described_class.new(authorization_definition:) }

  let(:authorization_definition) { instance_double(AuthorizationDefinition, editors: [editor]) }

  let(:editor) { Editor.all.first }

  it_behaves_like 'new authorization request facade'

  describe '#already_integrated_editors' do
    subject(:already_integrated_editors) { facade.already_integrated_editors }

    it { is_expected.to eq [] }
  end

  describe '#already_integrated_editors_ids' do
    subject(:already_integrated_editors_ids) { facade.already_integrated_editors_ids }

    it { is_expected.to eq [] }
  end

  describe '#decorated_editors_ids' do
    subject(:decorated_editors_ids) { facade.decorated_editors_ids }

    let(:expected_editors_ids) { [editor.id] }

    it { is_expected.to eq expected_editors_ids }
  end

  describe '#editors' do
    subject(:editors) { facade.editors }

    let(:expected_editors) { [editor] }

    it { is_expected.to eq expected_editors }
  end
end
