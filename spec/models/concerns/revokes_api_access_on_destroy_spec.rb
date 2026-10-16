RSpec.describe RevokesAPIAccessOnDestroy do
  let!(:grant) { create(:api_access_grant) }
  let(:application) { grant.oauth_application }

  it 'revokes the active grants of a deleted application and keeps the history' do
    application.destroy!

    expect(grant.reload).to have_attributes(
      revoked_automatically: true,
      revoked_by_email: nil,
      revoke_reason: 'Application supprimée',
      oauth_application_name: application.name
    )
    expect(grant).not_to be_active
  end

  it 'revokes grants when the owner is destroyed' do
    expect { application.owner.destroy! }.not_to raise_error
    expect(grant.reload).not_to be_active
  end

  it 'revokes every active grant of the application' do
    validation_grant = create(:api_access_grant, :validation, oauth_application: application, data_provider: grant.data_provider)

    application.destroy!

    expect([grant, validation_grant].map { |each_grant| each_grant.reload.active? }).to eq([false, false])
  end

  it 'destroys an application that has no grants' do
    application_without_grants = create(:oauth_application)

    expect { application_without_grants.destroy! }.to change(Doorkeeper::Application, :count).by(-1)
  end

  it 'keeps the first revoker when the grant was already revoked' do
    revoked_grant = create(:api_access_grant, :revoked)
    first_revoker = revoked_grant.revoked_by_email
    first_reason = revoked_grant.revoke_reason

    revoked_grant.oauth_application.destroy!

    expect(revoked_grant.reload).to have_attributes(revoked_by_email: first_revoker, revoke_reason: first_reason)
  end

  context 'when a grant cannot be revoked' do
    before { grant.update_column(:grant_reason, '') }

    it 'aborts the destroy and keeps the application' do
      expect { application.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
      expect(Doorkeeper::Application.exists?(application.id)).to be(true)
      expect(grant.reload).to be_active
    end
  end
end
