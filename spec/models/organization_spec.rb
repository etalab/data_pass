RSpec.describe Organization do
  it 'has valid factories' do
    expect(build(:organization, siret: '21920023500014')).to be_valid
  end

  describe '#categorie_juridique_label' do
    subject { organization.categorie_juridique_label }

    context 'with an organization with an insee payload' do
      let(:organization) { build(:organization, siret: '13002526500013') }

      it { is_expected.to eq('Service central d\'un ministère') }
    end

    context 'with an organization without an insee payload' do
      let(:organization) { build(:organization) }

      it { is_expected.to be_nil }
    end
  end
end
