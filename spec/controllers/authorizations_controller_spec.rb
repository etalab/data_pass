RSpec.describe AuthorizationsController do
  describe 'GET #show' do
    subject(:show_authorization) { get :show, params: { id: } }

    let(:user) { create(:user) }
    let(:authorization) { create(:authorization, applicant: user, slug: 'some slug') }

    before do
      sign_in(user)
    end

    context 'when the id param is a slug' do
      let(:id) { authorization.slug }

      it 'redirects permanently to the numeric ID URL' do
        expect(show_authorization).to redirect_to(authorization_path(authorization))
        expect(show_authorization).to have_http_status(:moved_permanently)
      end
    end

    context 'when the id param is the numeric ID' do
      let(:id) { authorization.id }

      it 'renders the show page' do
        expect(show_authorization).to have_http_status(:ok)
      end
    end
  end
end
