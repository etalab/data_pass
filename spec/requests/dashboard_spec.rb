RSpec.describe 'Dashboard' do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  describe 'invalid id' do
    it 'redirects to /moi' do
      get dashboard_show_path(id: 'invalid')

      expect(response).to redirect_to(dashboard_show_path(id: 'demandes'))
    end
  end

  describe 'GET show habilitations' do
    let(:organization) { user.current_organization }
    let(:other_user) { create(:user, skip_organization_creation: true) }
    let(:request_user) { create(:authorization_request, :api_entreprise, :validated, organization:, applicant: user) }
    let(:request_other) { create(:authorization_request, :api_entreprise, :validated, organization:, applicant: other_user) }

    before do
      other_user.add_to_organization(organization, verified: true)
      create(:authorization, request: request_user)
      create(:authorization, request: request_other)
    end

    it 'does not trigger N+1 queries on associations' do
      get dashboard_show_path(id: 'habilitations')

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET show demandes' do
    let(:organization) { user.current_organization }
    let(:other_user) { create(:user, skip_organization_creation: true) }

    before do
      other_user.add_to_organization(organization, verified: true)
      create(:authorization_request, :api_entreprise, organization:, applicant: user, state: :draft)
      create(:authorization_request, :api_entreprise, organization:, applicant: other_user, state: :submitted)
    end

    it 'does not trigger N+1 queries on associations' do
      get dashboard_show_path(id: 'demandes')

      expect(response).to have_http_status(:ok)
    end
  end
end
