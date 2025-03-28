RSpec.describe Organization do
  it 'has valid factories' do
    expect(build(:organization, siret: '21920023500014')).to be_valid
  end

  describe '#categorie_juridique' do
    subject { organization.categorie_juridique }

    context 'with an organization with an insee payload' do
      let(:organization) { build(:organization, siret: '13002526500013') }

      it { is_expected.to be_a(CategorieJuridique) }

      it 'returns the correct categorie juridique' do
        expect(subject.code).to eq('7120')
        expect(subject.libelle).to eq('Service central d\'un ministère')
      end
    end

    context 'with an organization without an insee payload' do
      let(:organization) { build(:organization) }

      it { is_expected.to be_nil }
    end
  end

  describe '#closed?' do
    subject { organization }

    context 'with open etablissement' do
      let(:organization) { build(:organization, siret: '21920023500014') }

      it { is_expected.not_to be_closed }
    end

    context 'with closed etablissement' do
      let(:organization) { build(:organization, siret: '21920023500022') }

      it { is_expected.to be_closed }
    end

    context 'with organization without insee payload' do
      let(:organization) { build(:organization, siret: '41040946000756') }

      it { is_expected.not_to be_closed }
    end
  end
end
