RSpec.describe UserRoles do
  describe '#managed_fd_slugs' do
    subject { user.managed_fd_slugs }

    context 'when user has no FD-level manager role' do
      let(:user) { build(:user, :manager, authorization_request_types: %w[api_entreprise]) }

      it { is_expected.to eq([]) }
    end

    context 'when user has FD-level manager roles' do
      let(:user) { build(:user, roles: %w[dinum:*:manager dgfip:*:manager dinum:api_entreprise:instructor]) }

      it { is_expected.to contain_exactly('dinum', 'dgfip') }
    end

    context 'when user has FD-level non-manager role' do
      let(:user) { build(:user, roles: %w[dinum:*:reporter]) }

      it { is_expected.to eq([]) }
    end
  end

  describe '#manages_role?' do
    subject(:result) { manager.manages_role?(role) }

    context 'when manager has the manager role on the definition' do
      let(:manager) { create(:user, :manager, authorization_request_types: %i[api_entreprise]) }

      context 'when the role is on the same definition' do
        let(:role) { 'dinum:api_entreprise:reporter' }

        it { is_expected.to be true }
      end

      context 'when the role is on another definition' do
        let(:role) { 'dinum:api_particulier:reporter' }

        it { is_expected.to be false }
      end

      context 'when the role is FD-wildcard for the same provider' do
        let(:role) { 'dinum:*:reporter' }

        it { is_expected.to be false }
      end
    end

    context 'when manager has the FD-wildcard manager role' do
      let(:manager) { create(:user, roles: ['dinum:*:manager']) }

      context 'when the role is FD-wildcard on the same provider' do
        let(:role) { 'dinum:*:reporter' }

        it { is_expected.to be true }
      end

      context 'when the role is on a definition of the same provider' do
        let(:role) { 'dinum:api_entreprise:reporter' }

        it { is_expected.to be true }
      end

      context 'when the role is on a definition of another provider' do
        let(:role) { 'dgfip:api_impot_particulier:reporter' }

        it { is_expected.to be false }
      end
    end

    context 'when the role is admin' do
      let(:manager) { create(:user, roles: ['dinum:*:manager']) }
      let(:role) { 'admin' }

      it { is_expected.to be false }
    end

    context 'when the role string is malformed' do
      let(:manager) { create(:user, :manager, authorization_request_types: %i[api_entreprise]) }
      let(:role) { 'not-a-valid-role' }

      it { is_expected.to be false }
    end
  end

  describe '#managed_by?' do
    subject(:result) { target.managed_by?(manager) }

    let(:manager) { create(:user, :manager, authorization_request_types: %i[api_entreprise]) }

    context 'when the target has at least one role within the manager scope' do
      let(:target) { create(:user, roles: %w[dinum:api_entreprise:reporter dinum:api_particulier:instructor]) }

      it { is_expected.to be true }
    end

    context 'when the target has no role within the manager scope' do
      let(:target) { create(:user, roles: %w[dinum:api_particulier:instructor]) }

      it { is_expected.to be false }
    end

    context 'when the target has no roles at all' do
      let(:target) { create(:user, roles: []) }

      it { is_expected.to be false }
    end
  end

  describe '#reporter?' do
    subject { user.reporter?(authorization_request_type) }

    context 'when user is an admin' do
      let(:user) { create(:user, :admin) }

      context 'without authorization_request_type' do
        let(:authorization_request_type) { nil }

        it { is_expected.to be_truthy }
      end

      context 'with authorization_request_type' do
        let(:authorization_request_type) { 'api_entreprise' }

        it { is_expected.to be_truthy }
      end
    end

    context 'when user is not a reporter' do
      let(:user) { build(:user) }

      context 'without authorization_request_type' do
        let(:authorization_request_type) { nil }

        it { is_expected.to be_falsey }
      end

      context 'with authorization_request_type' do
        let(:authorization_request_type) { 'api_entreprise' }

        it { is_expected.to be_falsey }
      end
    end

    context 'when user is a reporter' do
      let(:user) { build(:user, :reporter, authorization_request_types: %w[api_entreprise]) }

      context 'without authorization_request_type' do
        let(:authorization_request_type) { nil }

        it { is_expected.to be_truthy }
      end

      context 'with authorization_request_type' do
        context 'when authorization_request_type matches' do
          let(:authorization_request_type) { 'api_entreprise' }

          it { is_expected.to be_truthy }
        end

        context 'when authorization_request_type does not matche' do
          let(:authorization_request_type) { 'api_particulier' }

          it { is_expected.to be_falsey }
        end
      end
    end

    context 'when user is an instructor' do
      let(:user) { build(:user, :instructor, authorization_request_types: %w[api_entreprise]) }

      context 'without authorization_request_type' do
        let(:authorization_request_type) { nil }

        it { is_expected.to be_truthy }
      end

      context 'with authorization_request_type' do
        context 'when authorization_request_type matches' do
          let(:authorization_request_type) { 'api_entreprise' }

          it { is_expected.to be_truthy }
        end

        context 'when authorization_request_type does not matche' do
          let(:authorization_request_type) { 'api_particulier' }

          it { is_expected.to be_falsey }
        end
      end
    end

    context 'when user is a manager' do
      let(:user) { build(:user, :manager, authorization_request_types: %w[api_entreprise]) }

      context 'without authorization_request_type' do
        let(:authorization_request_type) { nil }

        it { is_expected.to be_truthy }
      end

      context 'with authorization_request_type' do
        context 'when authorization_request_type matches' do
          let(:authorization_request_type) { 'api_entreprise' }

          it { is_expected.to be_truthy }
        end

        context 'when authorization_request_type does not matche' do
          let(:authorization_request_type) { 'api_particulier' }

          it { is_expected.to be_falsey }
        end
      end
    end
  end

  describe '#fd_reporter?' do
    context 'when user has an FD-level reporter role on the provider' do
      let(:user) { create(:user, :fd_reporter, data_provider_slugs: ['dinum']) }

      it { expect(user.fd_reporter?('dinum')).to be true }
    end

    context 'when user has a definition-level reporter role under the provider' do
      let(:user) { create(:user, :reporter, authorization_request_types: %w[api_entreprise]) }

      it { expect(user.fd_reporter?('dinum')).to be true }
    end

    context 'when user has a role on another provider' do
      let(:user) { create(:user, :fd_reporter, data_provider_slugs: ['dgfip']) }

      it { expect(user.fd_reporter?('dinum')).to be false }
    end

    context 'when user is an admin' do
      let(:user) { create(:user, :admin) }

      it { expect(user.fd_reporter?('dinum')).to be true }
    end

    context 'when user has a manager role on the provider' do
      let(:user) { create(:user, :fd_manager, data_provider_slugs: ['dinum']) }

      it { expect(user.fd_reporter?('dinum')).to be true }
    end

    context 'when user has no role' do
      let(:user) { create(:user) }

      it { expect(user.fd_reporter?('dinum')).to be false }
    end
  end

  describe '#instructor?' do
    subject { user.instructor?(authorization_request_type) }

    context 'when user is not an instructor' do
      let(:user) { build(:user) }

      context 'without authorization_request_type' do
        let(:authorization_request_type) { nil }

        it { is_expected.to be_falsey }
      end

      context 'with authorization_request_type' do
        let(:authorization_request_type) { 'api_entreprise' }

        it { is_expected.to be_falsey }
      end
    end

    context 'when user is an instructor' do
      let(:user) { build(:user, :instructor, authorization_request_types: %w[api_entreprise]) }

      context 'without authorization_request_type' do
        let(:authorization_request_type) { nil }

        it { is_expected.to be_truthy }
      end

      context 'with authorization_request_type' do
        context 'when authorization_request_type matches' do
          let(:authorization_request_type) { 'api_entreprise' }

          it { is_expected.to be_truthy }
        end

        context 'when authorization_request_type does not matche' do
          let(:authorization_request_type) { 'api_particulier' }

          it { is_expected.to be_falsey }
        end
      end
    end

    context 'when user is a manager' do
      let(:user) { build(:user, :manager, authorization_request_types: %w[api_entreprise]) }

      context 'without authorization_request_type' do
        let(:authorization_request_type) { nil }

        it { is_expected.to be_truthy }
      end

      context 'with authorization_request_type' do
        context 'when authorization_request_type matches' do
          let(:authorization_request_type) { 'api_entreprise' }

          it { is_expected.to be_truthy }
        end

        context 'when authorization_request_type does not matche' do
          let(:authorization_request_type) { 'api_particulier' }

          it { is_expected.to be_falsey }
        end
      end
    end
  end

  describe '#manager?' do
    subject { user.manager?(authorization_request_type) }

    context 'when user is not a manager' do
      let(:user) { build(:user) }

      context 'without authorization_request_type' do
        let(:authorization_request_type) { nil }

        it { is_expected.to be_falsey }
      end

      context 'with authorization_request_type' do
        let(:authorization_request_type) { 'api_entreprise' }

        it { is_expected.to be_falsey }
      end
    end

    context 'when user is a manager' do
      let(:user) { build(:user, :manager, authorization_request_types: %w[api_entreprise]) }

      context 'without authorization_request_type' do
        let(:authorization_request_type) { nil }

        it { is_expected.to be_truthy }
      end

      context 'with authorization_request_type' do
        context 'when authorization_request_type matches' do
          let(:authorization_request_type) { 'api_entreprise' }

          it { is_expected.to be_truthy }
        end

        context 'when authorization_request_type does not matche' do
          let(:authorization_request_type) { 'api_particulier' }

          it { is_expected.to be_falsey }
        end
      end
    end
  end

  describe '#authorization_definition_roles_as' do
    subject { user.authorization_definition_roles_as(kind).map(&:id) }

    let(:kind) { 'instructor' }

    context 'when user is not an instructor' do
      let(:user) { build(:user) }

      it { is_expected.to be_empty }
    end

    context 'when user is an instructor' do
      let(:user) { build(:user, :instructor, authorization_request_types:) }
      let(:authorization_request_types) { %w[api_entreprise api_particulier] }

      let(:api_entreprise_definition) { AuthorizationDefinition.find('api_entreprise') }
      let(:api_particulier_definition) { AuthorizationDefinition.find('api_particulier') }

      it { is_expected.to contain_exactly('api_entreprise', 'api_particulier') }
    end

    context 'when the user is reporter and developer for the same authorization definition' do
      let(:kind) { 'reporter' }

      let(:user) { build(:user, :instructor, authorization_request_types: %w[api_entreprise]) }

      before do
        user.grant_role(:developer, 'api_entreprise')
        user.save
      end

      it { is_expected.to contain_exactly('api_entreprise') }
    end
  end
end
