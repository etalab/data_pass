RSpec.describe Instruction::AuthorizationDefinitionPolicy do
  describe '#index?' do
    subject { described_class.new(UserContext.new(user), AuthorizationDefinition).index? }

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

  describe '#show?' do
    subject { described_class.new(UserContext.new(user), authorization_definition).show? }

    let(:authorization_definition) { AuthorizationDefinition.find('api_entreprise') }

    context 'when user is an admin' do
      let(:user) { create(:user, :admin) }

      it { is_expected.to be true }
    end

    context 'when user is a reporter on the definition' do
      let(:user) { create(:user, :reporter, authorization_request_types: %w[api_entreprise]) }

      it { is_expected.to be true }
    end

    context 'when user is an instructor on the definition' do
      let(:user) { create(:user, :instructor, authorization_request_types: %w[api_entreprise]) }

      it { is_expected.to be true }
    end

    context 'when user is a manager on the definition' do
      let(:user) { create(:user, :manager, authorization_request_types: %w[api_entreprise]) }

      it { is_expected.to be true }
    end

    context 'when user is a reporter on another definition' do
      let(:user) { create(:user, :reporter, authorization_request_types: %w[hubee_cert_dc]) }

      it { is_expected.to be false }
    end

    context 'when user has no role' do
      let(:user) { create(:user) }

      it { is_expected.to be false }
    end
  end

  describe '#initiate_request?' do
    subject { described_class.new(UserContext.new(user), authorization_definition).initiate_request? }

    let(:authorization_definition) { AuthorizationDefinition.find('api_entreprise') }

    context 'when user is an instructor on the definition' do
      let(:user) { create(:user, :instructor, authorization_request_types: %w[api_entreprise]) }

      it { is_expected.to be true }
    end

    context 'when user is a reporter on the definition' do
      let(:user) { create(:user, :reporter, authorization_request_types: %w[api_entreprise]) }

      it { is_expected.to be false }
    end

    context 'when user is an instructor on a definition without the instructor_drafts feature' do
      let(:authorization_definition) { AuthorizationDefinition.find('hubee_dila') }
      let(:user) { create(:user, :instructor, authorization_request_types: %w[hubee_dila]) }

      it { is_expected.to be false }
    end
  end
end
