RSpec.describe DataProviderPolicy do
  let(:instance) { described_class.new(UserContext.new(user), data_provider) }
  let(:user) { create(:user, :admin) }
  let(:data_provider) { create(:data_provider) }

  describe '#destroy?' do
    subject { instance.destroy? }

    context 'when the data provider is deletable' do
      before { allow(data_provider).to receive(:deletable?).and_return(true) }

      it { is_expected.to be true }
    end

    context 'when the data provider is not deletable' do
      before { allow(data_provider).to receive(:deletable?).and_return(false) }

      it { is_expected.to be false }
    end
  end
end
