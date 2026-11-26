RSpec.describe 'Eligibility tree of the wallet registry' do
  let(:tree_path) { '/demandes/registre-wallet/nouveau' }
  let(:form_path) { '/formulaires/registre-wallet/demande/nouveau' }

  def answer_links
    response.parsed_body.css('[data-eligibility-result-target="store"] a.fr-btn').map { |link| [link.text.strip, link['href']] }
  end

  context 'when signed out' do
    it 'asks who registers the organization before showing the start page' do
      get tree_path

      expect(response.parsed_body.at_css('h1').text).to eq('Enregistrer votre organisation au registre du portefeuille européen')
      expect(response.parsed_body.at_css('title').text).to eq('Enregistrer votre organisation au registre du portefeuille européen - DataPass')
      expect(response.body).to include('Votre réponse détermine la façon de vous connecter.', 'Le dirigeant d’une entreprise', 'Un agent d’une administration ou d’une collectivité', 'Une association')
      expect(response.body).not_to include('Bienvenue sur DataPass !')
    end

    it 'gives the executive and the public agent a way in, and the association none' do
      get tree_path

      expect(answer_links).to eq([
        ['Commencer l’enregistrement', '/demandes/registre_wallet/nouveau?eligibility_confirmed=true&parcours=dirigeant'],
        ['Commencer l’enregistrement', '/demandes/registre_wallet/nouveau?eligibility_confirmed=true&parcours=agent']
      ])
      expect(response.parsed_body.at_css('#association-outcome').text).to include('Écrivez au support du registre')
    end

    it 'sends a visitor of the form address to the tree, remembering the form' do
      get form_path

      expect(response).to redirect_to('/demandes/registre_wallet/nouveau?formulaire=registre-wallet')
    end

    it 'keeps the answer for the return after signing in' do
      get "#{tree_path}?eligibility_confirmed=true&parcours=agent"

      expect(session[:return_to_after_sign_in]).to end_with("#{tree_path}?eligibility_confirmed=true&parcours=agent")
    end
  end

  context 'when the registry is closed' do
    before do
      allow(FeatureFlag).to receive(:enabled?).and_call_original
      allow(FeatureFlag).to receive(:enabled?).with('registre_wallet').and_return(false)
    end

    it 'does not show the tree' do
      get tree_path

      expect(response).to have_http_status(:not_found)
    end
  end

  context 'when signed in' do
    let(:user) { create(:user, skip_organization_creation: true) }

    before do
      user.add_to_organization(organization, current: true, verified: true)
      sign_in(user)
    end

    context 'with a public agent' do
      let(:organization) { create(:organization) }

      it 'skips the tree and opens the introduction, the answer being for display only' do
        get "#{tree_path}?eligibility_confirmed=true&parcours=dirigeant"

        expect(response).to redirect_to(form_path)

        follow_redirect!

        expect(response.parsed_body.at_css('#wallet_registry_capacity')).to be_present
      end

      it 'shows the tree again to change the answer' do
        get "#{tree_path}?changer_de_reponse=true"

        expect(response.parsed_body.at_css('h1').text).to eq('Enregistrer votre organisation au registre du portefeuille européen')
      end
    end

    context 'with a company the applicant does not lead, according to ProConnect' do
      let(:organization) { create(:organization, siret: '32816124500027') }

      it 'sends the introduction back to the definition page, which shows the refusal' do
        get form_path

        expect(response).to redirect_to('/demandes/registre_wallet/nouveau')

        get "#{tree_path}?parcours=dirigeant"

        expect(response.parsed_body.at_css('#wallet_registry_refusal')).to be_present
        expect(response.parsed_body.at_css('#wallet_registry_capacity')).to be_nil
      end

      it 'does not start a request when the answer says executive' do
        get '/formulaires/registre-wallet/demande/commencer?parcours=dirigeant'

        expect(response).to redirect_to('/demandes/registre_wallet/nouveau')
      end
    end
  end
end
