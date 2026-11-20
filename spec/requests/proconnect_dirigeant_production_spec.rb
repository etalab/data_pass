RSpec.describe 'ProConnect dirigeant journey in production' do
  let(:user) { create(:user) }

  before do
    allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
    OmniAuth.config.mock_auth[:proconnect_dirigeant] = OmniAuth::AuthHash.new(
      provider: :proconnect_dirigeant,
      uid: user.external_id,
      info: { email: user.email },
      extra: {
        acr: OmniAuth::Strategies::ProconnectDirigeant::DIRIGEANT_ACR_VALUE,
        raw_info: { sub: user.external_id, siret: user.current_organization.siret }
      }
    )
    sign_in(user)
  end

  after { OmniAuth.config.mock_auth[:proconnect_dirigeant] = nil }

  context 'when its setting is not set' do
    it 'does not serve the dirigeant verification page' do
      get dirigeant_verification_path

      expect(response).to have_http_status(:not_found)
    end

    it 'does not start the dirigeant certification' do
      post '/auth/proconnect_dirigeant'

      expect(response).to have_http_status(:not_found)
    end

    it 'does not run the dirigeant callback' do
      OmniAuth.config.mock_auth[:proconnect_dirigeant] = :invalid_credentials

      get '/auth/proconnect_dirigeant/callback'

      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when its setting opens the journey' do
    before { Setting.set(:proconnect_dirigeant_open, 'true') }

    it 'starts the dirigeant certification' do
      post '/auth/proconnect_dirigeant'

      expect(response).to redirect_to(%r{/auth/proconnect_dirigeant/callback})
    end
  end
end
