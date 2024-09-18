RSpec.describe ExternalReopenAuthorizationRequestsController do
  describe 'GET #create' do
    subject(:reopen_from_external) { get :create, params: { id: authorization_request.id } }

    let(:user) { create(:user) }

    before do
      sign_in(user)
    end

    context 'when the authorization request is not validated' do
      let(:authorization_request) { create(:authorization_request, applicant: user) }

      it 'does not reopen the authorization request' do
        expect { reopen_from_external }.not_to change { authorization_request.reload.state }
      end

      it 'redirects to the authorization summary request page' do
        reopen_from_external

        expect(response).to redirect_to(summary_authorization_request_form_path(id: authorization_request.id, form_uid: authorization_request.form.uid))
      end
    end

    context 'when the authorization request is validated' do
      let(:authorization_request) { create(:authorization_request, :validated, applicant: user) }

      it 'reopens the authorization request' do
        expect { reopen_from_external }.to change { authorization_request.reload.state }.from('validated').to('draft')
      end

      it 'redirects to the authorization summary request page' do
        reopen_from_external

        expect(response).to redirect_to(summary_authorization_request_form_path(id: authorization_request.id, form_uid: authorization_request.form.uid))
      end
    end
  end
end
