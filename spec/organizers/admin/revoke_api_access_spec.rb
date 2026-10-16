RSpec.describe Admin::RevokeAPIAccess do
  subject(:organizer) { described_class.call(admin:, grant:, reason:) }

  let(:admin) { create(:user, :admin) }
  let(:reason) { 'Le fournisseur retire son consentement' }
  let(:grant) { create(:api_access_grant) }
  let(:application) { grant.oauth_application }

  before { application.update!(scopes: 'public read_authorizations submit_authorizations') }

  it 'keeps the row and records who, when and why' do
    organizer

    expect(grant.reload).to have_attributes(revoked_by_email: admin.email, revoke_reason: reason)
    expect(grant.revoked_at).to be_present
  end

  it 'removes the scope when it was the last active grant of that action' do
    organizer

    expect(application.reload.scopes.to_a).to match_array(%w[public read_authorizations])
  end

  context 'when another active grant of the same action exists for another provider' do
    let(:other_definition) { AuthorizationDefinition.find('api_impot_particulier') }

    before do
      application.owner.grant_role(:developer, other_definition.id)
      application.owner.save!
      other_provider = DataProvider.find_by(slug: other_definition.provider_slug) || create(:data_provider, slug: other_definition.provider_slug)
      create(:api_access_grant, oauth_application: application, data_provider: other_provider)
    end

    it 'keeps the scope' do
      expect(other_definition.provider_slug).not_to eq(grant.data_provider.slug)
      organizer

      expect(application.reload.scopes.to_a).to include('submit_authorizations')
    end
  end

  context 'when the application had no explicit scopes before its grant' do
    before { application.update_column(:scopes, '') }

    it 'is left with the default scopes written explicitly' do
      organizer

      expect(application.reload.scopes.to_s).to eq('public read_authorizations')
    end
  end

  context 'when the reason is blank' do
    let(:reason) { '' }

    it 'fails and leaves the grant active' do
      expect(organizer).to be_a_failure
      expect(grant.reload).to be_active
    end
  end

  context 'when the grant was already revoked' do
    let(:grant) { create(:api_access_grant, :revoked) }
    let!(:first_reason) { grant.revoke_reason }

    it 'fails with an explicit error and keeps the first revocation' do
      expect(organizer).to be_a_failure
      expect(organizer.model.errors[:base]).to be_present
      expect(grant.reload.revoke_reason).to eq(first_reason)
    end
  end

  context 'when the application already holds a grant of the other action' do
    before do
      create(:api_access_grant, :validation, oauth_application: application, data_provider: grant.data_provider)
      application.update!(scopes: 'public read_authorizations submit_authorizations validate_authorizations')
    end

    it 'keeps the scope of the other action' do
      organizer

      expect(application.reload.scopes.to_a).to match_array(%w[public read_authorizations validate_authorizations])
    end
  end

  context 'when the scope sync fails' do
    before { application.update_column(:name, '') }

    it 'rolls the revocation back' do
      expect { organizer }.to raise_error(ActiveRecord::RecordInvalid)
      expect(grant.reload).to be_active
    end
  end
end
