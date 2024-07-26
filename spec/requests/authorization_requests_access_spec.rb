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
          create(:authorization_request, :portail_hubee_demarche_certdc, organization: user.current_organization)
        end

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
      describe 'in draft state' do
        let(:authorization_request) { create(:authorization_request, :portail_hubee_demarche_certdc, :draft, organization: user.current_organization, applicant: user) }

        it { is_expected.to have_http_status(:ok) }
      end

      describe 'in submitted state' do
        let(:authorization_request) { create(:authorization_request, :portail_hubee_demarche_certdc, :submitted, organization: user.current_organization, applicant: user) }

        it 'redirects to summary' do
          expect(show_authorization_request).to redirect_to(summary_authorization_request_form_path(form_uid: authorization_request.form_uid, id: authorization_request.id))
        end
      end
    end

    context 'when user is applicant but has not the correct current organization' do
      let(:another_organization) do
        organization = create(:organization)
        user.organizations << organization
        organization
      end

      let(:authorization_request) { create(:authorization_request, :portail_hubee_demarche_certdc, applicant: user, organization: another_organization) }

      it_behaves_like 'an unauthorized access'
    end
  end

  describe 'summary' do
    subject(:summary_authorization_request) do
      get summary_authorization_request_form_path(form_uid: authorization_request.form_uid, id: authorization_request.id)

      response
    end

    context 'when user is applicant and has the correct current organization' do
      let(:authorization_request) { create(:authorization_request, :portail_hubee_demarche_certdc, organization: user.current_organization, applicant: user) }

      context 'when authorization request is in draft and not fully filled' do
        let(:authorization_request) { create(:authorization_request, :api_entreprise, :draft, organization: user.current_organization, applicant: user) }

        it 'redirects to the form' do
          expect(summary_authorization_request).to redirect_to(authorization_request_form_path(id: authorization_request.id, form_uid: authorization_request.form_uid))
        end
      end
    end

    context 'when user is within the organization but not the applicant' do
      let(:authorization_request) { create(:authorization_request, :portail_hubee_demarche_certdc, organization: user.current_organization) }

      it { is_expected.to have_http_status(:ok) }

      it 'renders the summary' do
        expect(summary_authorization_request).to render_template('authorization_request_forms/summary')
      end
    end

    context 'when user is applicant but has not the correct current organization' do
      let(:another_organization) do
        organization = create(:organization)
        user.organizations << organization
        organization
      end

      let(:authorization_request) { create(:authorization_request, :portail_hubee_demarche_certdc, applicant: user, organization: another_organization) }

      it_behaves_like 'an unauthorized access'
    end
  end
end
