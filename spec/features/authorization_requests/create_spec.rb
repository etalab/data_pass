RSpec.describe 'Create authorization request' do
  let(:user) { create(:user) }
  let(:authorization_request_form) { AuthorizationRequestForm.find('portail-hubee-demarche-certdc') }
  let(:authorization_request_class) { authorization_request_form.authorization_request_class }

  before do
    sign_in(user)
  end

  describe 'elements' do
    subject do
      visit new_authorization_request_form_path(form_uid: authorization_request_form.uid)

      page
    end

    it 'does not have a submit authorization request button' do
      expect(subject).not_to have_button('submit_authorization_request')
    end
  end

  describe 'filling the form' do
    subject do
      visit new_authorization_request_form_path(form_uid: authorization_request_form.uid)

      within(css_id(authorization_request_class)) do
        click_button 'save_authorization_request'
      end
    end

    it 'creates a new authorization request linked to user' do
      expect { subject }.to change(AuthorizationRequest, :count).by(1)

      authorization_request = AuthorizationRequest.last

      expect(authorization_request.applicant).to eq(user)
    end
  end
end
