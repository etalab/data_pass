RSpec.describe ReopenAuthorizationsController, type: :controller do
  subject(:get_new_reopening) { get :new, params: { authorization_id: authorization.id, authorization_request_id: authorization.request_id } }

  let!(:valid_authorization) { create(:authorization, applicant: user, slug: friendly_id) }
  let!(:invalid_authorization) { create(:authorization, slug: friendly_id) }
  let(:friendly_id) { '2024-01-01' }

  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  context 'when we try to reopen an authorization belonging to the current user' do
    let(:authorization) { valid_authorization }

    it 'is ok' do
      expect(get_new_reopening).to have_http_status(:ok)
    end
  end

  context 'when we try to reopen an authorization not belonging to the current user' do
    let(:authorization) { invalid_authorization }

    it 'redirects to dashboard path' do
      expect(get_new_reopening).to have_http_status(302)
      expect(response).to redirect_to(dashboard_path)
    end
  end
end
