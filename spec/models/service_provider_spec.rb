RSpec.describe ServiceProvider do
  describe '.all' do
    it 'returns a list of all editors' do
      expect(described_class.all).to be_all { |a| a.is_a? ServiceProvider }
    end
  end

  describe '#already_integrated?' do
    subject(:already_integrated) { editor.already_integrated?(scope:) }

    let(:scope) { :api_entreprise }

    context 'when the editor is already integrated' do
      let(:editor) { described_class.new(already_integrated: %w[api_entreprise]) }

      it { is_expected.to be true }

      context 'with a different scope' do
        let(:scope) { 'other_scope' }

        it { is_expected.to be false }
      end
    end

    context 'when the editor is not already integrated' do
      let(:editor) { described_class.new(already_integrated: []) }

      it { is_expected.to be false }
    end
  end
end
