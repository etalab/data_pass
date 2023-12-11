RSpec.describe 'Unique authorization form' do
  context 'when user has already an unique authorization request' do
    let(:user) { create(:user) }
    let(:authorization_request_form) { AuthorizationRequestForm.find('portail-hubee-demarche-certdc') }

    before do
      sign_in(user)
      create(:authorization_request, :hubee_cert_dc, applicant: user)
    end

    describe 'try to fill a new Hubee authorization' do
      subject do
        visit new_authorization_request_path(form_uid: authorization_request_form.uid)
      end

      it 'redirects to home page with a flash message' do
        subject

        expect(page).to have_css('.fr-alert--warning')
        expect(page).to have_current_path(dashboard_path, ignore_query: true)
      end
    end
  end
end
