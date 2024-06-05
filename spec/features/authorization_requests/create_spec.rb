RSpec.describe 'Starting a new authorization request' do
  subject do
    visit new_authorization_request_form_path(form_uid: authorization_request_form.uid)

    click_link_or_button dom_id(authorization_request_form, :start_authorization_request)
  end

  let(:user) { create(:user) }
  let(:authorization_request_form) { AuthorizationRequestForm.find('portail-hubee-demarche-certdc') }
  let(:authorization_request_class) { authorization_request_form.authorization_request_class }

  before do
    sign_in(user)
  end

  it 'does not create a new authorization request (no longer persisted when starting)' do
    expect { subject }.not_to change(AuthorizationRequest, :count)
  end
end
