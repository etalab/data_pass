RSpec.describe Instruction::DataProviderPolicy do
  subject(:policy) { described_class.new(UserContext.new(user), data_provider) }

  let!(:data_provider) { create(:data_provider, :dinum) }
  let!(:other_provider) { create(:data_provider, :dgfip) }

  describe '#show?' do
    subject { policy.show? }

    context 'when user is admin' do
      let(:user) { create(:user, :admin) }

      it { is_expected.to be true }
    end

    context 'when user has a reporter role on the FD' do
      let(:user) { create(:user, :fd_reporter, data_provider_slugs: %w[dinum]) }

      it { is_expected.to be true }
    end

    context 'when user has a reporter role on another FD' do
      let(:user) { create(:user, :fd_reporter, data_provider_slugs: %w[cnam]) }

      it { is_expected.to be false }
    end

    context 'when user has no role' do
      let(:user) { create(:user) }

      it { is_expected.to be false }
    end
  end

  describe 'Scope#resolve' do
    subject { described_class::Scope.new(UserContext.new(user), DataProvider).resolve }

    context 'when user is admin' do
      let(:user) { create(:user, :admin) }

      it 'returns all providers' do
        expect(subject.count).to eq(DataProvider.count)
      end
    end

    context 'when user has a single FD role' do
      let(:user) { create(:user, :fd_instructor, data_provider_slugs: %w[dinum]) }

      it 'returns only that provider' do
        expect(subject.pluck(:slug)).to eq(%w[dinum])
      end
    end

    context 'when user has no role' do
      let(:user) { create(:user) }

      it { is_expected.to be_empty }
    end
  end
end
