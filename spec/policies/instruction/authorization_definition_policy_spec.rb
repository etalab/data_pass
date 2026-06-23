RSpec.describe Instruction::AuthorizationDefinitionPolicy do
  subject(:policy) { described_class.new(UserContext.new(user), AuthorizationDefinition) }

  describe '#index?' do
    subject { policy.index? }

    context 'when user is an admin' do
      let(:user) { create(:user, :admin) }

      it { is_expected.to be true }
    end

    context 'when user is a reporter' do
      let(:user) { create(:user, :reporter, authorization_request_types: %i[api_entreprise]) }

      it { is_expected.to be true }
    end

    context 'when user is a manager' do
      let(:user) { create(:user, :manager, authorization_request_types: %i[api_entreprise]) }

      it { is_expected.to be true }
    end

    context 'when user is an instructor' do
      let(:user) { create(:user, :instructor, authorization_request_types: %i[api_entreprise]) }

      it { is_expected.to be true }
    end

    context 'when user has no role' do
      let(:user) { create(:user) }

      it { is_expected.to be false }
    end
  end
end
