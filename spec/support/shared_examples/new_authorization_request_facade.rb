RSpec.shared_examples 'new authorization request facade' do
  it { is_expected.to respond_to(:authorization_definition) }

  describe '#authorization_definition_name' do
    subject(:authorization_definition_name) { facade.authorization_definition_name }

    let(:authorization_definition) { instance_double(AuthorizationDefinition, name: 'ReallyGoodDefinition') }

    it { is_expected.to eq 'ReallyGoodDefinition' }
  end

  describe '#decorated_editors' do
    subject(:decorated_editors) { facade.decorated_editors }

    it { is_expected.to all(be_a(EditorDecorator)) }
  end

  describe '#editors_index' do
    subject(:editors_index) { facade.editors_index }

    let(:decorated_editors) { [alpha_editor, digit_editor] }
    let(:digit_editor) { Editor.new(name: '42 editor').decorate }
    let(:alpha_editor) { Editor.new(name: 'A editor').decorate }
    let(:sorted_indexed_editors) { [['123', [digit_editor]], ['A', [alpha_editor]]] }

    before do
      allow(facade).to receive(:decorated_editors).and_return(decorated_editors)
    end

    it { is_expected.to include(*sorted_indexed_editors) }
  end

  describe '#public_available_forms' do
    subject(:public_available_forms) { facade.public_available_forms }

    let(:authorization_definition) { instance_double(AuthorizationDefinition, public_available_forms: [form]) }
    let(:form) { AuthorizationRequestForm.new }

    it { is_expected.to all(be_a(AuthorizationRequestFormDecorator)) }
  end
end
