RSpec.describe 'Local sign-in' do
  let(:user) { create(:user) }

  def stub_tokens(tokens)
    allow(Rails.application.credentials).to receive(:local_sign_in_tokens).and_return(tokens)
  end

  describe 'GET /local-sign-in' do
    context 'when no token is configured (open environment)' do
      before { stub_tokens(nil) }

      it 'signs the user in and redirects to the dashboard' do
        get '/local-sign-in', params: { email: user.email }

        expect(response).to redirect_to(dashboard_path)
      end
    end

    context 'when tokens are configured (protected environment)' do
      before { stub_tokens(dgfip: 's3cret') }

      it 'returns 404 without a token' do
        get '/local-sign-in', params: { email: user.email }

        expect(response).to have_http_status(:not_found)
      end

      it 'returns 404 with a wrong token' do
        get '/local-sign-in', params: { email: user.email, token: 'nope' }

        expect(response).to have_http_status(:not_found)
      end

      it 'signs in with a valid token and remembers it in a cookie' do
        get '/local-sign-in', params: { email: user.email, token: 's3cret' }

        expect(response).to redirect_to(dashboard_path)
        expect(response.cookies['local_sign_in_token']).to be_present
      end

      it 'stays unlocked on a later request thanks to the cookie' do
        get '/local-sign-in', params: { email: user.email, token: 's3cret' }
        get '/local-sign-in', params: { email: user.email }

        expect(response).to redirect_to(dashboard_path)
      end

      it 'logs which provider token was used' do
        allow(Rails.logger).to receive(:info)

        get '/local-sign-in', params: { email: user.email, token: 's3cret' }

        expect(Rails.logger).to have_received(:info).with(a_string_matching(/\[local-sign-in\].*dgfip/))
      end
    end
  end

  describe 'the quick sign-in panel on the login page' do
    context 'when tokens are configured and the visitor is not unlocked' do
      before { stub_tokens(dgfip: 's3cret') }

      it 'is hidden' do
        get '/'

        expect(response.body).not_to include('Connexion rapide')
      end
    end
  end
end
