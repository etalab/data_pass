RSpec.describe AuthorizationRequestFormsController do
  let(:user) { create(:user) }
  let(:organization) { create(:organization) }

  before do
    user.add_to_organization(organization, current: true)
    sign_in user
  end

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

    context 'with valid form uid' do
      let(:form_uid) { 'hubee-cert-dc' }

      context 'when organization has no existing authorization requests' do
        it 'allows creating new authorization request' do
          new_authorization_request_form

          expect(response).to be_successful
          expect(assigns(:authorization_request_form)).to be_present
          expect(response.body).not_to include('Vous ne pouvez pas créer de nouvelle habilitation')
        end
      end

      context 'when organization has refused authorization request' do
        before do
          create(:authorization_request, :hubee_cert_dc, :refused, organization:)
        end

        it 'allows creating new authorization request (refused requests should not block)' do
          new_authorization_request_form

          expect(response).to be_successful
          expect(response.body).not_to include('Vous ne pouvez pas créer de nouvelle habilitation')
        end
      end

      context 'when organization has validated request with revoked authorization' do
        before do
          request = create(:authorization_request, :hubee_cert_dc, :validated, organization:)
          create(:authorization, request:, state: 'revoked', organization:)
        end

        it 'allows creating new authorization request (revoked authorization should not block)' do
          new_authorization_request_form

          expect(response).to be_successful
          expect(response.body).not_to include('Vous ne pouvez pas créer de nouvelle habilitation')
        end
      end

      context 'when organization has active authorization request' do
        before do
          create(:authorization_request, :hubee_cert_dc, :submitted, organization:)
        end

        it 'prevents creating new authorization request' do
          new_authorization_request_form

          expect(response).to be_successful
          expect(response.body).to include('Vous ne pouvez pas créer de nouvelle habilitation')
        end
      end

      context 'when organization has validated request with active authorization' do
        before do
          request = create(:authorization_request, :hubee_cert_dc, :validated, organization:)
          create(:authorization, request:, state: 'active', organization:)
        end

        it 'prevents creating new authorization request' do
          new_authorization_request_form

          expect(response).to be_successful
          expect(response.body).to include('Vous ne pouvez pas créer de nouvelle habilitation')
        end
      end
    end
  end
end
