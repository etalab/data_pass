RSpec.describe 'Admin::APIAccessGrants' do
  let(:owner) { create(:user, :developer, authorization_request_types: %w[api_entreprise]) }
  let(:application) { create(:oauth_application, owner:) }
  let(:data_provider) do
    slug = AuthorizationDefinition.find('api_entreprise').provider_slug
    DataProvider.find_by(slug:) || create(:data_provider, slug:)
  end
  let!(:grant) { create(:api_access_grant, oauth_application: application, data_provider:) }
  let(:creation_params) do
    {
      api_access_grant: {
        oauth_application_id: application.id,
        data_provider_id: data_provider.id,
        action: 'validation',
        grant_reason: 'Tentative sans droit'
      }
    }
  end

  shared_examples 'a refused access' do
    it 'redirects to the dashboard' do
      subject

      expect(response).to redirect_to(dashboard_path)
    end
  end

  context 'when the user is not an admin' do
    before { sign_in(create(:user, :instructor, authorization_request_types: %w[api_entreprise])) }

    describe 'GET /admin/acces-api' do
      subject { get admin_api_access_grants_path }

      it_behaves_like 'a refused access'
    end

    describe 'GET /admin/acces-api/new' do
      subject { get new_admin_api_access_grant_path }

      it_behaves_like 'a refused access'
    end

    describe 'POST /admin/acces-api' do
      subject { post admin_api_access_grants_path, params: creation_params }

      it_behaves_like 'a refused access'

      it 'does not create a grant' do
        expect { subject }.not_to change(APIAccessGrant, :count)
      end
    end

    describe 'GET /admin/acces-api/:id/revocation/new' do
      subject { get new_admin_api_access_grant_revocation_path(grant) }

      it_behaves_like 'a refused access'
    end

    describe 'POST /admin/acces-api/:id/revocation' do
      subject do
        post admin_api_access_grant_revocation_path(grant), params: { api_access_grant: { revoke_reason: 'Tentative sans droit' } }
      end

      it_behaves_like 'a refused access'

      it 'keeps the grant active' do
        subject

        expect(grant.reload).to be_active
      end
    end
  end

  context 'when nobody is signed in' do
    it 'does not create a grant' do
      expect { post admin_api_access_grants_path, params: creation_params }.not_to change(APIAccessGrant, :count)
    end

    it 'keeps the grant active' do
      post admin_api_access_grant_revocation_path(grant), params: { api_access_grant: { revoke_reason: 'Tentative' } }

      expect(grant.reload).to be_active
    end
  end
end
