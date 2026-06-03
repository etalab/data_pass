RSpec.describe Instruction::AuthorizationRequestFormPolicy do
  subject(:policy) { described_class.new(UserContext.new(user), form) }

  let(:form) { AuthorizationRequestForm.where(authorization_request_class: AuthorizationRequest::APIParticulier).first }

  describe '#show?' do
    subject { policy.show? }

    context 'when user is admin' do
      let(:user) { create(:user, :admin) }

      it { is_expected.to be true }
    end

    context 'when user has FD-wide role on the provider' do
      let(:user) { create(:user, :fd_reporter, data_provider_slugs: %w[dinum]) }

      it { is_expected.to be true }
    end

    context 'when user has a role on another definition' do
      let(:user) { create(:user, :reporter, authorization_request_types: %w[api_entreprise]) }

      it { is_expected.to be false }
    end
  end
end
