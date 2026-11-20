RSpec.describe 'Wallet registry start for an organization seen closed' do
  let(:user) { create(:user, skip_organization_creation: true) }
  let(:organization) { create(:organization, siret: '21920023500022') }

  before do
    user.add_to_organization(organization, current: true, verified: true)
    sign_in(user)
  end

  context 'when the INSEE data was refreshed in the last 24 hours' do
    it 'refuses the closed organization' do
      get '/formulaires/registre-wallet/demande/nouveau'

      expect(response.parsed_body.at_css('#wallet_registry_refusal').text).to include('est fermée dans le répertoire Sirene')
    end
  end

  context 'when the INSEE data is older than 24 hours' do
    before { organization.update!(last_insee_payload_updated_at: 2.days.ago) }

    it 'refreshes the INSEE data and shows a pending check instead of a refusal' do
      expect {
        get '/formulaires/registre-wallet/demande/nouveau'
      }.to have_enqueued_job(UpdateOrganizationINSEEPayloadJob).with(organization.id)

      refusal = response.parsed_body.at_css('#wallet_registry_refusal').text
      expect(refusal).to include('Nous vérifions les informations de votre organisation')
      expect(refusal).not_to include('est fermée dans le répertoire Sirene')
      expect(response.body).not_to include('Débuter ma demande')
    end

    it 'keeps the answer in the retry link' do
      get '/formulaires/registre-wallet/demande/nouveau?parcours=agent'

      expect(response.parsed_body.at_css('#wallet_registry_retry')['href']).to eq('/formulaires/registre-wallet/demande/nouveau?parcours=agent')
    end
  end
end
