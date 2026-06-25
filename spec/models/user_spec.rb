RSpec.describe User do
  it 'has valid factories' do
    expect(build(:user)).to be_valid
    expect(build(:user, :instructor)).to be_valid
  end

  describe 'validation ban_reason' do
    it 'est invalide si banned_at est présent sans ban_reason' do
      expect(build(:user, banned_at: Time.zone.now, ban_reason: nil)).not_to be_valid
    end

    it 'est valide si non banni sans ban_reason' do
      expect(build(:user, banned_at: nil, ban_reason: nil)).to be_valid
    end

    it 'est valide si banni avec une raison' do
      expect(build(:user, banned_at: Time.zone.now, ban_reason: 'Abus de service')).to be_valid
    end
  end

  describe '.instructor_for' do
    subject { described_class.instructor_for(authorization_request_type) }

    let(:authorization_request_type) { 'api_entreprise' }

    let!(:valid_instructor) { create(:user, :instructor, authorization_request_types: %i[api_entreprise]) }
    let!(:valid_instructor_with_multiple_authorization_type) { create(:user, :instructor, authorization_request_types: %i[api_entreprise api_particulier]) }
    let!(:invalid_instructor) { create(:user, :instructor, authorization_request_types: %i[api_particulier]) }
    let!(:valid_reporter) { create(:user, :reporter, authorization_request_types: %i[api_entreprise]) }
    let!(:valid_manager) { create(:user, :manager, authorization_request_types: %i[api_entreprise]) }

    it { is_expected.to contain_exactly(valid_instructor, valid_instructor_with_multiple_authorization_type, valid_manager) }
  end

  describe '.developer_for' do
    subject { described_class.developer_for(authorization_request_type) }

    let(:authorization_request_type) { 'api_entreprise' }

    let!(:valid_developer) { create(:user, :developer, authorization_request_types: %i[api_entreprise]) }
    let!(:valid_developer_with_multiple_authorization_type) { create(:user, :developer, authorization_request_types: %i[api_entreprise api_particulier]) }
    let!(:invalid_developer) { create(:user, :developer, authorization_request_types: %i[api_particulier]) }
    let!(:valid_reporter) { create(:user, :reporter, authorization_request_types: %i[api_entreprise]) }

    it { is_expected.to contain_exactly(valid_developer, valid_developer_with_multiple_authorization_type) }
  end

  describe '.reporter_for' do
    subject { described_class.reporter_for(authorization_request_type) }

    let(:authorization_request_type) { 'api_entreprise' }

    let!(:valid_developer) { create(:user, :developer, authorization_request_types: %i[api_entreprise]) }
    let!(:valid_instructor) { create(:user, :instructor, authorization_request_types: %i[api_entreprise]) }
    let!(:valid_instructor_with_multiple_authorization_type) { create(:user, :instructor, authorization_request_types: %i[api_entreprise api_particulier]) }
    let!(:invalid_instructor) { create(:user, :instructor, authorization_request_types: %i[api_particulier]) }
    let!(:valid_reporter) { create(:user, :reporter, authorization_request_types: %i[api_entreprise]) }

    it { is_expected.to contain_exactly(valid_reporter, valid_developer, valid_instructor, valid_instructor_with_multiple_authorization_type) }
  end

  describe '.manager_for' do
    subject { described_class.manager_for(authorization_request_type) }

    let(:authorization_request_type) { 'api_entreprise' }

    let!(:valid_manager) { create(:user, :manager, authorization_request_types: %i[api_entreprise]) }
    let!(:valid_manager_with_multiple_authorization_type) { create(:user, :manager, authorization_request_types: %i[api_entreprise api_particulier]) }
    let!(:invalid_manager) { create(:user, :manager, authorization_request_types: %i[api_particulier]) }
    let!(:valid_instructor) { create(:user, :instructor, authorization_request_types: %i[api_entreprise]) }

    it { is_expected.to contain_exactly(valid_manager, valid_manager_with_multiple_authorization_type) }
  end

  describe '.with_any_role_on' do
    subject { described_class.with_any_role_on(definition_ids) }

    let!(:api_entreprise_reporter) { create(:user, :reporter, authorization_request_types: %i[api_entreprise]) }
    let!(:api_entreprise_manager) { create(:user, :manager, authorization_request_types: %i[api_entreprise]) }
    let!(:api_particulier_reporter) { create(:user, :reporter, authorization_request_types: %i[api_particulier]) }
    let!(:no_role_user) { create(:user) }
    let!(:admin_only) { create(:user, :admin) }

    context 'when definition_ids contains a single id' do
      let(:definition_ids) { ['api_entreprise'] }

      it { is_expected.to contain_exactly(api_entreprise_reporter, api_entreprise_manager) }
    end

    context 'when definition_ids contains several ids' do
      let(:definition_ids) { %w[api_entreprise api_particulier] }

      it { is_expected.to contain_exactly(api_entreprise_reporter, api_entreprise_manager, api_particulier_reporter) }
    end

    context 'when definition_ids is empty' do
      let(:definition_ids) { [] }

      it { is_expected.to eq(described_class.none) }
    end

    context 'when definition_ids matches no users' do
      let(:definition_ids) { ['unknown_api'] }

      it { is_expected.to be_empty }
    end

    context 'when a user holds an FD-wildcard role for the provider' do
      let(:definition_ids) { ['api_entreprise'] }
      let!(:fd_wildcard_manager) { create(:user, roles: ['dinum:*:manager']) }

      it 'includes the FD-wildcard role holder, so an FD-manager sees their own row' do
        expect(subject).to include(fd_wildcard_manager)
      end
    end
  end

  describe '#settings on instruction_submit_notifications' do
    subject { user.instruction_submit_notifications_for_api_entreprise }

    let(:user) { create(:user) }

    it { is_expected.to be_truthy }

    context 'when it sets to false' do
      let(:user) { create(:user, instruction_submit_notifications_for_api_entreprise: false) }

      it { is_expected.to be_falsey }
    end

    context 'when it sets to "0"' do
      let(:user) { create(:user, instruction_submit_notifications_for_api_entreprise: '0') }

      it { is_expected.to be_falsey }
    end

    context 'when it sets to "1"' do
      let(:user) { create(:user, instruction_submit_notifications_for_api_entreprise: '1') }

      it { is_expected.to be_truthy }
    end

    context 'when it sets to true' do
      let(:user) { create(:user, instruction_submit_notifications_for_api_entreprise: true) }

      it { is_expected.to be_truthy }
    end
  end

  describe '#full_name' do
    subject { user.full_name }

    let(:user) { build(:user, given_name: given_name, family_name: family_name) }

    context 'when given_name is not capitalized' do
      let(:given_name) { 'john' }
      let(:family_name) { 'doe' }

      it { is_expected.to eq('DOE John') }
    end

    context 'when given_name has a dash' do
      let(:given_name) { 'JEAN-MICHEL' }
      let(:family_name) { 'Doe' }

      it { is_expected.to eq('DOE Jean-Michel') }
    end

    context 'when given_name has a space' do
      let(:given_name) { 'JEAN MICHEL' }
      let(:family_name) { 'Doe' }

      it { is_expected.to eq('DOE Jean Michel') }
    end
  end

  describe '#add_to_organization' do
    let(:user) { create(:user) }
    let(:organization) { create(:organization) }

    context 'with valid identity federator' do
      let(:identity_provider_uid) { '71144ab3-ee1a-4401-b7b3-79b44f7daeeb' }
      let(:identity_federator) { 'pro_connect' }

      it 'creates organization user with identity provider uid and verified reason' do
        result = user.add_to_organization(
          organization,
          verified: true,
          verified_reason: 'from ProConnect identity',
          identity_provider_uid: identity_provider_uid,
          identity_federator: identity_federator
        )

        expect(result).to be_persisted
        expect(result.identity_provider_uid).to eq(identity_provider_uid)
        expect(result.identity_federator).to eq(identity_federator)
        expect(result.verified).to be true
        expect(result.verified_reason).to eq('from ProConnect identity')
        expect(result.identity_provider).not_to be_nil
      end
    end

    context 'with unknown identity federator' do
      it 'creates organization user without identity provider uid and no verified reason' do
        result = user.add_to_organization(
          organization,
          verified: false,
          identity_provider_uid: nil,
          identity_federator: 'unknown'
        )

        expect(result).to be_persisted
        expect(result.identity_provider_uid).to be_nil
        expect(result.identity_federator).to eq('unknown')
        expect(result.verified).to be false
        expect(result.verified_reason).to be_nil
        expect(result.identity_provider).to be_unknown
      end
    end
  end

  describe '#banned?' do
    subject { user.banned? }

    context 'when user has no ban' do
      let(:user) { create(:user) }

      it { is_expected.to be false }
    end

    context 'when user is banned' do
      let(:user) { create(:user, banned_at: Time.zone.now, ban_reason: 'Abus de service') }

      it { is_expected.to be true }
    end
  end

  describe '#roles=' do
    it 'clears memoized role sets so role checks reflect the new roles' do
      user = build(:user, roles: ['dinum:api_entreprise:developer'])

      expect(user.developer?).to be true

      user.roles = ['dinum:api_entreprise:reporter']

      expect(user.developer?).to be false
    end
  end

  describe '.banned' do
    subject { described_class.banned }

    let!(:active_user) { create(:user) }
    let!(:banned_user) { create(:user, banned_at: Time.zone.now, ban_reason: 'Abus de service') }

    it { is_expected.to contain_exactly(banned_user) }
  end
end
