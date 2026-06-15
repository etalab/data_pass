RSpec.describe Instruction::DataProviderPolicy do
  subject(:policy) { described_class.new(UserContext.new(user), data_provider) }

  let(:data_provider) { create(:data_provider, :dinum) }

  describe '#index?' do
    subject { policy.index? }

    context 'when user is a reporter' do
      let(:user) { create(:user, :reporter) }

      it { is_expected.to be true }
    end

    context 'when user is an instructor' do
      let(:user) { create(:user, :instructor) }

      it { is_expected.to be true }
    end

    context 'when user is a manager' do
      let(:user) { create(:user, :manager) }

      it { is_expected.to be true }
    end

    context 'when user has no role' do
      let(:user) { create(:user) }

      it { is_expected.to be false }
    end
  end

  describe 'Scope' do
    subject(:scope) { described_class::Scope.new(UserContext.new(user), DataProvider).resolve }

    let!(:dinum_provider) { create(:data_provider, :dinum) }
    let!(:dgfip_provider) { create(:data_provider, :dgfip) }

    context 'when user is an admin' do
      let(:user) { create(:user, :admin) }

      it 'returns all data providers' do
        expect(scope).to include(dinum_provider, dgfip_provider)
      end
    end

    context 'when user has fd_reporter role on the provider' do
      let(:user) { create(:user, :fd_reporter, data_provider_slugs: ['dinum']) }

      it 'returns only the providers the user has access to' do
        expect(scope).to include(dinum_provider)
        expect(scope).not_to include(dgfip_provider)
      end
    end

    context 'when user has fd_instructor role on the provider' do
      let(:user) { create(:user, :fd_instructor, data_provider_slugs: ['dinum']) }

      it 'returns only the providers the user has access to' do
        expect(scope).to include(dinum_provider)
        expect(scope).not_to include(dgfip_provider)
      end
    end

    context 'when user has fd_manager role on the provider' do
      let(:user) { create(:user, :fd_manager, data_provider_slugs: ['dinum']) }

      it 'returns only the providers the user has access to' do
        expect(scope).to include(dinum_provider)
        expect(scope).not_to include(dgfip_provider)
      end
    end

    context 'when user has a definition-level reporter role' do
      let(:user) { create(:user, :reporter, authorization_request_types: %w[api_entreprise]) }

      it 'returns the provider derived from the definition, not unrelated ones' do
        expect(scope).to include(dinum_provider)
        expect(scope).not_to include(dgfip_provider)
      end
    end

    context 'when user has no roles' do
      let(:user) { create(:user) }

      it { is_expected.to be_empty }
    end
  end
end
