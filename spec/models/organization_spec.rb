RSpec.describe Organization do
  it 'has valid factories' do
    expect(build(:organization, siret: '21920023500014')).to be_valid
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
