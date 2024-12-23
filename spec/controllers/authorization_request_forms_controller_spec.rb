RSpec.describe AuthorizationRequestFormsController, type: :controller do
  describe 'GET #new' do
    subject(:new_authorization_request_form) { get :new, params: { form_uid: } }

    context 'with invalid form uid' do
      let(:form_uid) { 'invalid' }

      it 'redirects to root path with an error message' do
        new_authorization_request_form

        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("Le formulaire demandé n'existe pas")
      end
    end
  end
end
