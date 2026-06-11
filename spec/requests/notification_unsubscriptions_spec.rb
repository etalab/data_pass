RSpec.describe 'Notification unsubscriptions' do
  describe 'POST /desabonnement-notifications with an invalid token while impersonating' do
    let(:admin) { create(:user, :admin) }
    let(:impersonated_user) { create(:user, :instructor, authorization_request_types: %w[api_entreprise]) }

    before do
      sign_in(admin)
      post admin_impersonate_path(impersonation: { email: impersonated_user.email, reason: 'Support #12345' })
    end

    it 'renders the invalid page instead of raising' do
      post notification_unsubscriptions_path, params: { token: 'invalid-token' }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Lien invalide ou expiré')
    end
  end

  describe 'GET /desabonnement-notifications when Matomo is configured' do
    around do |example|
      original_matomo_id = Rails.application.config.matomo_id
      Rails.application.config.matomo_id = '307'
      example.run
      Rails.application.config.matomo_id = original_matomo_id
    end

    it 'does not load the Matomo tracker on the unsubscription pages' do
      get notification_unsubscriptions_path, params: { token: 'invalid-token' }

      expect(response.body).not_to include('setTrackerUrl')
    end
  end
end
