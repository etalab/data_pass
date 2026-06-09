RSpec.describe Developer::OauthApplicationPolicy do
  subject(:policy) { described_class.new(UserContext.new(user), application) }

  let(:owner) { create(:user, :developer) }
  let(:application) { create(:oauth_application, owner:) }

  describe '#index?' do
    subject { policy.index? }

    context 'when user has developer role' do
      let(:user) { owner }

      it { is_expected.to be true }
    end

    context 'when user has no developer role' do
      let(:user) { create(:user) }

      it { is_expected.to be false }
    end
  end

  describe '#create?' do
    subject { policy.create? }

    context 'when user has developer role' do
      let(:user) { owner }

      it { is_expected.to be true }
    end

    context 'when user has no developer role' do
      let(:user) { create(:user) }

      it { is_expected.to be false }
    end
  end

  describe '#destroy?' do
    subject { policy.destroy? }

    context 'when user owns the application' do
      let(:user) { owner }

      it { is_expected.to be true }
    end

    context 'when user does not own the application' do
      let(:user) { create(:user, :developer) }

      it { is_expected.to be false }
    end
  end

  describe 'Scope' do
    subject(:scope) { described_class::Scope.new(UserContext.new(user), Doorkeeper::Application).resolve }

    let(:other_user) { create(:user, :developer) }
    let!(:own_application) { create(:oauth_application, owner:) }
    let!(:other_application) { create(:oauth_application, owner: other_user) }

    context 'when user has developer role' do
      let(:user) { owner }

      it 'returns only own applications' do
        expect(scope).to include(own_application)
        expect(scope).not_to include(other_application)
      end
    end
  end
end
