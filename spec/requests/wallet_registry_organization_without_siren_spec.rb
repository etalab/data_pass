RSpec.describe 'Wallet registry start for an organization without SIREN' do
  let(:user) { create(:user, skip_organization_creation: true) }
  let(:organization) { create(:organization, siret: '32816124500027') }
  let(:origin) { '/formulaires/registre-wallet/demande/nouveau?parcours=dirigeant' }

  before do
    user.add_to_organization(organization, current: true, verified: true)
    sign_in(user)
    organization.update!(legal_entity_registry: 'foreign_registry')
    OmniAuth.config.mock_auth[:proconnect_dirigeant] = OmniAuth::AuthHash.new(
      provider: :proconnect_dirigeant,
      uid: user.external_id,
      info: { email: user.email },
      extra: { acr: OmniAuth::Strategies::ProconnectDirigeant::DIRIGEANT_ACR_VALUE, raw_info: { sub: user.external_id, siret: '32816124500027' } }
    )
  end

  after { OmniAuth.config.mock_auth[:proconnect_dirigeant] = nil }

  it 'explains that the executive certification needs a SIREN' do
    post '/auth/proconnect_dirigeant', params: { return_to: origin }
    follow_redirect! while response.redirect?

    expect(response.parsed_body.at_css('#wallet_registry_refusal').text).to include('Votre organisation n’a pas de SIREN : la certification dirigeant n’est pas possible.')
  end
end
