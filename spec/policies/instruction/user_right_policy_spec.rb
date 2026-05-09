RSpec.describe Instruction::UserRightPolicy do
  subject(:policy) { described_class.new(UserContext.new(user), target) }

  let(:target) { create(:user, :reporter, authorization_request_types: %i[api_entreprise]) }

  describe '#index?' do
    subject { policy.index? }

    context 'when user is a manager' do
      let(:user) { create(:user, :manager, authorization_request_types: %i[api_entreprise]) }

      it { is_expected.to be true }
    end

    context 'when user is only an instructor' do
      let(:user) { create(:user, :instructor, authorization_request_types: %i[api_entreprise]) }

      it { is_expected.to be false }
    end

    context 'when user is only a reporter' do
      let(:user) { create(:user, :reporter, authorization_request_types: %i[api_entreprise]) }

      it { is_expected.to be false }
    end

    context 'when user has no role' do
      let(:user) { create(:user) }

      it { is_expected.to be false }
    end
  end

  describe '#new?' do
    subject { policy.new? }

    context 'when user is a manager' do
      let(:user) { create(:user, :manager, authorization_request_types: %i[api_entreprise]) }

      it { is_expected.to be true }
    end

    context 'when user is not a manager' do
      let(:user) { create(:user, :reporter, authorization_request_types: %i[api_entreprise]) }

      it { is_expected.to be false }
    end
  end

  describe '#create?' do
    subject { policy.create? }

    context 'when user is a manager' do
      let(:user) { create(:user, :manager, authorization_request_types: %i[api_entreprise]) }

      it { is_expected.to be true }
    end

    context 'when user is not a manager' do
      let(:user) { create(:user, :reporter, authorization_request_types: %i[api_entreprise]) }

      it { is_expected.to be false }
    end
  end

  describe '#edit?' do
    subject { policy.edit? }

    context 'when user is a manager on the target definition' do
      let(:user) { create(:user, :manager, authorization_request_types: %i[api_entreprise]) }

      it { is_expected.to be true }
    end

    context 'when user targets themselves' do
      let(:user) { create(:user, :manager, authorization_request_types: %i[api_entreprise]) }
      let(:target) { user }

      it { is_expected.to be false }
    end

    context 'when target has no role on any managed definition' do
      let(:user) { create(:user, :manager, authorization_request_types: %i[api_entreprise]) }
      let(:target) { create(:user, :reporter, authorization_request_types: %i[api_particulier]) }

      it { is_expected.to be false }
    end

    context 'when user is not a manager' do
      let(:user) { create(:user, :instructor, authorization_request_types: %i[api_entreprise]) }

      it { is_expected.to be false }
    end
  end

  describe '#destroy?' do
    subject { policy.destroy? }

    context 'when user is a manager on the target definition' do
      let(:user) { create(:user, :manager, authorization_request_types: %i[api_entreprise]) }

      it { is_expected.to be true }
    end

    context 'when user targets themselves' do
      let(:user) { create(:user, :manager, authorization_request_types: %i[api_entreprise]) }
      let(:target) { user }

      it { is_expected.to be false }
    end
  end

  describe '#edit? with FD-level scope' do
    subject { policy.edit? }

    context 'when user is an FD-manager and target has an FD-wildcard role on that FD' do
      let(:user) { create(:user, roles: ['dinum:*:manager']) }
      let(:target) { create(:user, roles: ['dinum:*:reporter']) }

      it { is_expected.to be true }
    end

    context 'when user is an FD-manager and target has a definition role under that FD' do
      let(:user) { create(:user, roles: ['dinum:*:manager']) }
      let(:target) { create(:user, roles: ['dinum:api_entreprise:reporter']) }

      it { is_expected.to be true }
    end

    context 'when user is a definition-manager and target has an FD-wildcard role (out of scope)' do
      let(:user) { create(:user, :manager, authorization_request_types: %i[api_entreprise]) }
      let(:target) { create(:user, roles: ['dinum:*:reporter']) }

      it { is_expected.to be false }
    end
  end
end
