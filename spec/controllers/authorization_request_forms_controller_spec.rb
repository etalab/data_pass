RSpec.describe AuthorizationRequestFormsController do
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

    context 'with prefill query parameters' do
      let(:form_uid) { 'api-particulier' }
      let(:user) { create(:user) }

      before { sign_in(user) }

      it 'stores filtered prefill data in session, scoped by form_uid' do
        get :new, params: { form_uid:, intitule: 'Mon projet', not_an_attribute: 'noise' }

        expect(session[:authorization_request_prefill]).to eq(
          'form_uid' => form_uid,
          'data' => { 'intitule' => 'Mon projet' },
        )
      end

      it 'does not store anything when no params match an attribute' do
        get :new, params: { form_uid:, not_an_attribute: 'noise' }

        expect(session[:authorization_request_prefill]).to be_nil
      end

      it 'clears stale prefill for the same form on a bare revisit' do
        get :new, params: { form_uid:, intitule: 'Premier passage' }
        expect(session[:authorization_request_prefill]).to be_present

        get :new, params: { form_uid: }
        expect(session[:authorization_request_prefill]).to be_nil
      end

      it 'preserves prefill for another form on a bare revisit' do
        get :new, params: { form_uid:, intitule: 'Premier passage' }

        get :new, params: { form_uid: 'api-entreprise-socle-de-base' }
        expect(session[:authorization_request_prefill]).to include('form_uid' => form_uid)
      end
    end
  end
end
