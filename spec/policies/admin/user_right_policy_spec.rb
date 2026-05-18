RSpec.describe Admin::UserRightPolicy do
  subject(:policy) { described_class.new(UserContext.new(user), target) }

  let(:target) { create(:user, :reporter, authorization_request_types: %i[api_entreprise]) }

  describe '#index?' do
    subject { policy.index? }

    context 'when user is admin' do
      let(:user) { create(:user, :admin) }

      it { is_expected.to be true }
    end

    context 'when user is only a manager' do
      let(:user) { create(:user, :manager, authorization_request_types: %i[api_entreprise]) }

      it { is_expected.to be false }
    end

    context 'when user has no role' do
      let(:user) { create(:user) }

      it { is_expected.to be false }
    end
  end

  describe '#new?' do
    subject { policy.new? }

    context 'when user is admin' do
      let(:user) { create(:user, :admin) }

      it { is_expected.to be true }
    end

    context 'when user is not admin' do
      let(:user) { create(:user, :manager, authorization_request_types: %i[api_entreprise]) }

      it { is_expected.to be false }
    end
  end

  describe '#edit?' do
    subject { policy.edit? }

    context 'when user is admin and targets another user' do
      let(:user) { create(:user, :admin) }

      it { is_expected.to be true }
    end

    context 'when user is admin and targets themselves' do
      let(:user) { create(:user, :admin) }
      let(:target) { user }

      it { is_expected.to be false }
    end

    context 'when user is admin and target has only roles under another provider' do
      let(:user) { create(:user, :admin) }
      let(:target) { create(:user, roles: ['dgfip:api_ficoba:developer']) }

      it { is_expected.to be true }
    end

    context 'when user is not admin' do
      let(:user) { create(:user, :manager, authorization_request_types: %i[api_entreprise]) }

      it { is_expected.to be false }
    end
  end

  describe '#destroy?' do
    subject { policy.destroy? }

    context 'when user is admin and targets another user' do
      let(:user) { create(:user, :admin) }

      it { is_expected.to be true }
    end

    context 'when user is admin and targets themselves' do
      let(:user) { create(:user, :admin) }
      let(:target) { user }

      it { is_expected.to be false }
    end
  end
end
