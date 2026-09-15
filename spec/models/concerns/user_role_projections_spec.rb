RSpec.describe UserRoleProjections do
  describe '#distinct_role_types' do
    subject { user.distinct_role_types }

    context 'when the user has no role' do
      let(:user) { build(:user) }

      it { is_expected.to eq([]) }
    end

    context 'when the user holds several role types across definitions' do
      let(:user) { build(:user, roles: %w[dinum:api_entreprise:manager dinum:api_particulier:instructor]) }

      it { is_expected.to contain_exactly('manager', 'instructor') }
    end

    context 'when the same role type appears on several definitions' do
      let(:user) { build(:user, roles: %w[dinum:api_entreprise:manager dinum:api_particulier:manager]) }

      it 'deduplicates the role type' do
        expect(subject).to contain_exactly('manager')
      end
    end

    context 'when the user is admin' do
      let(:user) { build(:user, roles: %w[admin dinum:api_entreprise:instructor]) }

      it 'lists admin literally, without expanding it to every role type' do
        expect(subject).to contain_exactly('admin', 'instructor')
      end
    end

    context 'when the user only holds an FD-level role' do
      let(:user) { build(:user, roles: %w[dinum:*:manager]) }

      it 'keeps the literal role type' do
        expect(subject).to contain_exactly('manager')
      end
    end
  end

  describe '#specific_authorization_definitions' do
    subject { user.specific_authorization_definitions.map(&:id) }

    context 'when the user has no role' do
      let(:user) { build(:user) }

      it { is_expected.to eq([]) }
    end

    context 'when the user holds specific-definition roles' do
      let(:user) { build(:user, roles: %w[dinum:api_entreprise:manager dinum:api_particulier:instructor]) }

      it { is_expected.to contain_exactly('api_entreprise', 'api_particulier') }
    end

    context 'when the same definition appears with several role types' do
      let(:user) { build(:user, roles: %w[dinum:api_entreprise:manager dinum:api_entreprise:developer]) }

      it 'deduplicates the definition' do
        expect(subject).to contain_exactly('api_entreprise')
      end
    end

    context 'when the user only holds implicit rights (FD-level and admin)' do
      let(:user) { build(:user, roles: %w[dinum:*:manager admin]) }

      it 'is empty, implicit rights are not specific API rights' do
        expect(subject).to eq([])
      end
    end
  end
end
