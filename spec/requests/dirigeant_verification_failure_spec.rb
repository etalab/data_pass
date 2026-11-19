RSpec.describe 'ProConnect dirigeant verification interrupted by ProConnect' do
  let(:user) { create(:user, skip_organization_creation: true) }
  let(:organization) { create(:organization, siret: '32816124500027') }
  let(:origin) { '/formulaires/registre-wallet/demande/nouveau' }

  before do
    user.add_to_organization(organization, current: true, verified: true)
    sign_in(user)
    OmniAuth.config.mock_auth[:proconnect_dirigeant] = :access_denied
  end

  after { OmniAuth.config.mock_auth[:proconnect_dirigeant] = nil }

  it 'goes back to the starting page' do
    post '/auth/proconnect_dirigeant', params: { siret_hint: organization.siret, return_to: origin }
    follow_redirect! while response.redirect? && !response.location.end_with?(origin)

    expect(response).to redirect_to(origin)
    expect(flash[:dirigeant_verification]).to eq('status' => 'failure', 'reason' => 'access_denied')
  end

  it 'forgets a previous certification' do
    OmniAuth.config.mock_auth[:proconnect_dirigeant] = OmniAuth::AuthHash.new(
      provider: :proconnect_dirigeant,
      uid: user.external_id,
      info: { email: user.email },
      extra: { acr: OmniAuth::Strategies::ProconnectDirigeant::DIRIGEANT_ACR_VALUE, raw_info: { sub: user.external_id, siret: organization.siret } }
    )
    get '/auth/proconnect_dirigeant/callback'
    expect(session[:dirigeant_verification]).to be_present

    OmniAuth.config.mock_auth[:proconnect_dirigeant] = :access_denied
    post '/auth/proconnect_dirigeant', params: { return_to: origin }
    follow_redirect! while response.redirect? && !response.location.end_with?(origin)

    expect(session[:dirigeant_verification]).to be_nil
  end
end
