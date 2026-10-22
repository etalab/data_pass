RSpec.describe APIAccessGrant do
  describe '.active' do
    it 'excludes revoked grants' do
      active_grant = create(:api_access_grant)
      create(:api_access_grant, :revoked)

      expect(described_class.active).to contain_exactly(active_grant)
    end
  end

  describe '.active_for?' do
    subject(:active_for) do
      described_class.active_for?(application: grant.oauth_application, data_provider_id:, action: 'submission')
    end

    let(:grant) { create(:api_access_grant) }
    let(:data_provider_id) { grant.data_provider_id }

    it { is_expected.to be true }

    context 'when the grant is for another action' do
      let(:grant) { create(:api_access_grant, :validation) }

      it { is_expected.to be false }
    end

    context 'when the grant is for another provider' do
      let(:data_provider_id) { create(:data_provider).id }

      it { is_expected.to be false }
    end

    context 'when the grant is revoked' do
      let(:grant) { create(:api_access_grant, :revoked) }

      it { is_expected.to be false }
    end

    context 'when the application is nil' do
      subject(:active_for) do
        described_class.active_for?(application: nil, data_provider_id: grant.data_provider_id, action: 'submission')
      end

      it { is_expected.to be false }
    end

    context 'when the provider is unknown' do
      let(:data_provider_id) { nil }

      it { is_expected.to be false }
    end
  end

  describe '#scope_name' do
    it 'maps each action to its OAuth scope' do
      expect(build(:api_access_grant).scope_name).to eq('submit_authorizations')
      expect(build(:api_access_grant, :validation).scope_name).to eq('validate_authorizations')
    end
  end

  describe 'granting the same right twice' do
    it 'is refused while the first grant is active' do
      first = create(:api_access_grant)
      duplicate = build(:api_access_grant, oauth_application: first.oauth_application, data_provider: first.data_provider)

      expect(duplicate.save).to be false
      expect(duplicate.errors.where(:base, :already_granted)).to be_present
    end

    it 'is allowed again once the first grant is revoked' do
      first = create(:api_access_grant, :revoked)
      again = build(:api_access_grant, oauth_application: first.oauth_application, data_provider: first.data_provider)

      expect(again.save).to be true
    end
  end

  describe 'creating a grant' do
    it 'copies the application name' do
      application = create(:oauth_application, name: 'Mon application', owner: create(:user, :developer, authorization_request_types: %w[api_entreprise]))

      expect(create(:api_access_grant, oauth_application: application).oauth_application_name).to eq('Mon application')
    end

    it 'sets granted_at when it is not given' do
      grant = create(:api_access_grant, granted_at: nil)

      expect(grant.granted_at).to be_present
    end

    it 'rejects an unknown action' do
      grant = build(:api_access_grant, action: 'deletion')

      expect(grant.save).to be false
      expect(grant.errors[:action]).to be_present
    end
  end

  describe 'granting to an unknown application' do
    it 'is refused with an error on the application' do
      grant = build(:api_access_grant, oauth_application: nil, oauth_application_id: 0)

      expect(grant.save).to be false
      expect(grant.errors[:oauth_application]).to be_present
    end
  end

  describe 'granting to an application whose owner cannot use the provider' do
    it 'is refused' do
      application = create(:oauth_application, owner: create(:user, :developer, authorization_request_types: %w[api_particulier]))
      grant = build(:api_access_grant, oauth_application: application, data_provider: create(:data_provider))

      expect(grant.save).to be false
      expect(grant.errors.where(:base, :not_covered_by_owner)).to be_present
    end
  end

  describe '#revoke!' do
    let(:grant) { create(:api_access_grant) }

    it 'records who, when and why and keeps the row' do
      grant.revoke!(by_email: 'admin@example.com', reason: 'Consentement retiré')

      expect(grant.reload).to have_attributes(revoked_by_email: 'admin@example.com', revoke_reason: 'Consentement retiré')
      expect(grant.revoked_at).to be_present
      expect(grant).not_to be_active
    end

    it 'returns a truthy value on success' do
      expect(grant.revoke!(by_email: 'admin@example.com', reason: 'Consentement retiré')).to be_truthy
    end

    it 'still works after the owner lost the developer role' do
      grant.oauth_application.owner.update!(roles: [])

      expect(grant.revoke!(by_email: 'admin@example.com', reason: 'Consentement retiré')).to be_truthy
      expect(grant.reload).not_to be_active
    end

    it 'does not overwrite a revocation made in the meantime' do
      stale = described_class.find(grant.id)
      grant.revoke!(by_email: 'first@example.com', reason: 'Premier motif')

      expect(stale.revoke!(by_email: 'second@example.com', reason: 'Second motif')).to be false
      expect(grant.reload.revoked_by_email).to eq('first@example.com')
    end

    it 'refuses a blank reason' do
      expect(grant.revoke!(by_email: 'admin@example.com', reason: '')).to be false
      expect(grant).to be_active
      expect(grant.reload).to be_active
    end

    it 'refuses a blank by_email' do
      expect(grant.revoke!(by_email: nil, reason: 'Consentement retiré')).to be false
      expect(grant).to be_active
      expect(grant.reload).to be_active
    end
  end

  describe '#revoke_automatically!' do
    let(:grant) { create(:api_access_grant) }

    it 'revokes without a revoking person' do
      grant.revoke_automatically!(reason: 'Application supprimée')

      expect(grant.reload).to have_attributes(revoked_automatically: true, revoked_by_email: nil, revoke_reason: 'Application supprimée')
      expect(grant).not_to be_active
    end

    it 'refuses a blank reason' do
      expect(grant.revoke_automatically!(reason: '')).to be false
      expect(grant.reload).to be_active
    end

    it 'keeps the first revocation when already revoked' do
      grant.revoke!(by_email: 'admin@example.com', reason: 'Premier motif')

      expect(grant.revoke_automatically!(reason: 'Second motif')).to be false
      expect(grant.reload).to have_attributes(revoked_automatically: false, revoked_by_email: 'admin@example.com')
    end
  end

  describe 'destroying a grant' do
    let(:owner) { create(:user, :developer, authorization_request_types: %w[api_entreprise]) }
    let(:application) { create(:oauth_application, owner:, scopes: 'public submit_authorizations') }
    let(:grant) { create(:api_access_grant, oauth_application: application) }

    it 'removes the scope that no active grant justifies any more' do
      grant.destroy!

      expect(application.reload.scopes.to_a).to eq(%w[public])
    end

    it 'does not fail when the application no longer exists' do
      grant
      application.delete

      expect { grant.reload.destroy! }.not_to raise_error
    end
  end

  describe 'Doorkeeper configuration' do
    it 'accepts every grant scope on an application' do
      application = build(:oauth_application, scopes: APIScopes::ALL.join(' '))

      expect(application).to be_valid
    end
  end
end
