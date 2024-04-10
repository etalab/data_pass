RSpec.describe CategorieJuridique do
  describe '#find' do
    subject(:find) { described_class.find(code) }

    let(:code) { '1000' }

    it 'works' do
      expect(find.libelle).to eq('Entrepreneur individuel')
    end
  end
end
