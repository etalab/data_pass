RSpec.describe CodeNAF do
  describe '#find' do
    subject { described_class.find(code) }

    context 'with a valid code' do
      context 'with a code with a dot' do
        let(:code) { '01.12Z' }

        it { is_expected.to be_a(described_class) }
        it { is_expected.to have_attributes(code: '0112Z', libelle: 'Culture du riz') }
      end

      context 'with a code without a dot' do
        let(:code) { '0112Z' }

        it { is_expected.to be_a(described_class) }
        it { is_expected.to have_attributes(code: '0112Z', libelle: 'Culture du riz') }
      end
    end
  end
end
