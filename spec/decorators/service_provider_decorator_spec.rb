RSpec.describe ServiceProviderDecorator do
  describe '#scroll_target' do
    subject(:scroll_target) { editor.decorate(context: decorator_context).scroll_target }

    let(:decorator_context) { { scope: :api_entreprise } }

    context 'when service provider is already integrated' do
      let(:editor) { ServiceProvider.new(already_integrated: %w[api_entreprise]) }

      it { is_expected.to eq('editor-already-integrated-disclaimer') }
    end

    context 'when service editor is not already integrated' do
      let(:editor) { ServiceProvider.new(already_integrated: %w[api_particulier]) }

      it { is_expected.to eq('forms') }
    end
  end
end
