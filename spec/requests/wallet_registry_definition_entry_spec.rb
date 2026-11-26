RSpec.describe 'Wallet registry entry through its definition path' do
  let(:user) { create(:user, skip_organization_creation: true) }
  let(:wallet_registry_form_path) { '/formulaires/registre-wallet/demande/nouveau' }

  before do
    user.add_to_organization(organization, current: true, verified: true)
    sign_in(user)
  end

  context 'when the applicant is a public agent' do
    let(:organization) { create(:organization) }

    it 'sends them to the wallet registry form' do
      get '/demandes/registre-wallet/nouveau'

      expect(response).to redirect_to(wallet_registry_form_path)
    end
  end

  context 'when the applicant belongs to a company without certification' do
    let(:organization) { create(:organization, siret: '32816124500027') }

    it 'shows the refusal on the definition page, without opening the form' do
      get '/demandes/registre-wallet/nouveau'

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.at_css('#wallet_registry_refusal')).to be_present
    end
  end

  context 'when the applicant is a certified executive' do
    let(:organization) { create(:organization, siret: '32816124500027') }

    before do
      OmniAuth.config.mock_auth[:proconnect_dirigeant] = OmniAuth::AuthHash.new(
        provider: :proconnect_dirigeant,
        uid: user.external_id,
        info: { email: user.email },
        extra: {
          acr: OmniAuth::Strategies::ProconnectDirigeant::DIRIGEANT_ACR_VALUE,
          raw_info: { sub: user.external_id, siret: organization.siret }
        }
      )
      get '/auth/proconnect_dirigeant/callback'
    end

    after { OmniAuth.config.mock_auth[:proconnect_dirigeant] = nil }

    it 'sends them to the wallet registry introduction' do
      get '/demandes/registre-wallet/nouveau'

      expect(response).to redirect_to(wallet_registry_form_path)

      follow_redirect!

      expect(response.parsed_body.at_css('#wallet_registry_capacity')).to be_present
    end
  end
end
