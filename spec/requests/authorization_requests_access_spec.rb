RSpec.describe 'Authorization requests access' do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  describe 'new' do
    subject(:new_authorization_request) do
      get new_authorization_request_form_path(form_uid: authorization_request_form.uid)

      response
    end

    context 'with a basic form' do
      let(:authorization_request_form) { AuthorizationRequestForm.find('portail-hubee-demarche-certdc') }

      context 'when there is no authorization request' do
        it { is_expected.to have_http_status(:ok) }
      end

      context 'when there is one authorization request' do
        before do
          create(:authorization_request, :hubee_cert_dc, organization: user.current_organization)
        end

        it_behaves_like 'an unauthorized access'
      end
    end

    context 'with a form which is not startable by applicant' do
      let(:authorization_request_form) { AuthorizationRequestForm.find('api-infinoe-production') }

      context 'when there is no authorization request' do
        it_behaves_like 'an unauthorized access'
      end
    end
  end

  describe 'show' do
    subject(:show_authorization_request) do
      get authorization_request_form_path(form_uid: authorization_request.form_uid, id: authorization_request.id)

      response
    end

    context 'when user is applicant and has the correct current organization' do
      let(:authorization_request) { create(:authorization_request, :hubee_cert_dc, organization: user.current_organization, applicant: user) }

      it { is_expected.to have_http_status(:ok) }
    end

    context 'when user is applicant but has not the correct current organization' do
      let(:another_organization) do
        organization = create(:organization)
        user.organizations << organization
        organization
      end

      let(:authorization_request) { create(:authorization_request, :hubee_cert_dc, applicant: user, organization: another_organization) }

      it_behaves_like 'an unauthorized access'
    end
  end
end
