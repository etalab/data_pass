RSpec.describe 'Authorization request form introduction' do
  it 'keeps the start page of a signed-out visitor out of the container layout, as before its own controller' do
    get authorization_request_form_introduction_path(form_uid: 'api-particulier')

    expect(response).to have_http_status(:ok)
    expect(response.body).not_to include('fr-container--main')
  end
end
