RSpec.describe EditorDecorator do
  describe '#scroll_target' do
    subject(:scroll_target) { editor.decorate(context: decorator_context).scroll_target }

    let(:decorator_context) { { scope: :api_entreprise } }

    context 'when editor is already integrated' do
      let(:editor) { Editor.new(already_integrated: %w[api_entreprise]) }

      it { is_expected.to eq('editor-already-integrated-disclaimer') }
    end

    context 'when editor is not already integrated' do
      let(:editor) { Editor.new(already_integrated: %w[api_particulier]) }

      it { is_expected.to eq('forms') }
    end
  end
end
