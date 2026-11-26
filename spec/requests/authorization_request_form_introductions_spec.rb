RSpec.describe 'Authorization request form introduction' do
  it 'sends a signed-out visitor to the definition page, which remembers the form they came for' do
    get authorization_request_form_introduction_path(form_uid: 'api-particulier')

    expect(response).to redirect_to(new_authorization_request_path(definition_id: 'api_particulier', formulaire: 'api-particulier'))
  end

  it 'captures the prefill of a partner link before sending a signed-out visitor away' do
    get authorization_request_form_introduction_path(form_uid: 'api-particulier', intitule: 'Mon service')

    expect(session[:authorization_request_prefill]).to be_present
  end

  it 'shows the introduction to a signed-in applicant' do
    sign_in(create(:user))

    get authorization_request_form_introduction_path(form_uid: 'api-particulier')

    expect(response).to have_http_status(:ok)
  end
end
