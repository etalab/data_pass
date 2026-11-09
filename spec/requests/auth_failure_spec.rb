RSpec.describe 'GET /auth/failure' do
  it 'redirects to the sign in page with the failure message' do
    get '/auth/failure'

    expect(response).to redirect_to(connexion_path)

    follow_redirect!

    expect(response.body).to include(I18n.t('sessions.failure.title'))
  end
end
