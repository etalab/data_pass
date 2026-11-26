RSpec.describe 'Sign in block of the unauthenticated starting page' do
  let(:agent_start_path) { '/demandes/registre-wallet/nouveau?eligibility_confirmed=true&parcours=agent' }
  let(:executive_start_path) { '/demandes/registre-wallet/nouveau?eligibility_confirmed=true&parcours=dirigeant' }

  def sign_in_forms
    response.parsed_body.css('form[action^="/auth/"]')
  end

  def hidden_value(form, name)
    form.at_css("input[name=\"#{name}\"]")&.[]('value')
  end

  def sign_in_private_company_member
    user = create(:user, skip_organization_creation: true)
    user.add_to_organization(create(:organization, siret: '32816124500027'), current: true, verified: true)
    sign_in(user)
  end

  it 'gives an executive a single ProConnect button that opens the executive journey' do
    get executive_start_path

    expect(sign_in_forms.size).to eq(1)
    expect(sign_in_forms.first['action']).to eq('/auth/proconnect')
    expect(hidden_value(sign_in_forms.first, 'parcours')).to eq('dirigeant')
    expect(hidden_value(sign_in_forms.first, 'return_to')).to eq('/formulaires/registre-wallet/demande/nouveau?parcours=dirigeant')
    expect(response.parsed_body.at_css('#wallet_registry_answer').text).to start_with('Vous avez répondu : le dirigeant d’une entreprise. ProConnect vous demandera')
  end

  it 'gives a public agent the usual ProConnect button alone' do
    get agent_start_path

    expect(sign_in_forms.size).to eq(1)
    expect(sign_in_forms.first['action']).to eq('/auth/proconnect')
    expect(hidden_value(sign_in_forms.first, 'parcours')).to be_nil
    expect(response.parsed_body.at_css('#wallet_registry_answer').text).to start_with('Vous avez répondu : un agent d’une administration')
  end

  it 'leads back to the eligibility tree to change the answer' do
    get agent_start_path

    expect(response.parsed_body.at_css('#wallet_registry_change_answer')['href']).to eq('/demandes/registre_wallet/nouveau')
  end

  it 'ignores an answer that the tree does not offer' do
    get '/demandes/registre-wallet/nouveau?eligibility_confirmed=true&parcours=admin'

    expect(response.parsed_body.at_css('#wallet_registry_answer')).to be_nil
    expect(sign_in_forms.size).to eq(1)
    expect(hidden_value(sign_in_forms.first, 'parcours')).to be_nil
  end

  it 'keeps the usual ProConnect button alone for any other form' do
    get '/demandes/api-entreprise/nouveau?eligibility_confirmed=true&formulaire=api-entreprise'

    expect(response.body).to include('Bienvenue sur DataPass !', 'login_pro_connect')
    expect(response.body).not_to include('wallet_registry_answer', 'wallet_registry_refusal')
    expect(sign_in_forms.size).to eq(1)
    expect(sign_in_forms.first.at_css('input[name="return_to"]')).to be_nil
  end

  context 'when ProConnect dirigeant is off' do
    before do
      allow(FeatureFlag).to receive(:enabled?).and_call_original
      allow(FeatureFlag).to receive(:enabled?).with(:proconnect_dirigeant).and_return(false)
    end

    it 'gives an executive the usual button, without promising the certification' do
      get executive_start_path

      expect(hidden_value(sign_in_forms.first, 'parcours')).to be_nil
      expect(response.parsed_body.at_css('#wallet_registry_answer').text).to eq('Vous avez répondu : le dirigeant d’une entreprise.')
    end

    it 'tells a private company that it cannot register online yet' do
      sign_in_private_company_member

      get '/formulaires/registre-wallet/demande/nouveau?parcours=dirigeant'

      expect(response.parsed_body.at_css('#wallet_registry_refusal').text).to include('ne peuvent pas encore s’enregistrer en ligne')
      expect(sign_in_forms.pluck('action')).to eq(['/auth/proconnect'])
    end
  end

  context 'when a signed in executive comes back refused' do
    before { sign_in_private_company_member }

    it 'restarts the certification of the organization of the connection' do
      get '/formulaires/registre-wallet/demande/nouveau?parcours=dirigeant'

      expect(sign_in_forms.pluck('action')).to eq(['/auth/proconnect_dirigeant'])
      expect(hidden_value(sign_in_forms.first, 'siret_hint')).to eq('32816124500027')
    end

    it 'offers the executive certification even without an answer, the certification being the only way in' do
      get '/formulaires/registre-wallet/demande/nouveau'

      expect(response.parsed_body.at_css('#wallet_registry_answer')).to be_nil
      expect(sign_in_forms.pluck('action')).to eq(['/auth/proconnect_dirigeant'])
      expect(hidden_value(sign_in_forms.first, 'siret_hint')).to eq('32816124500027')
    end

    it 'shows the refusal in the sign in section, under its title, before the answer' do
      get '/formulaires/registre-wallet/demande/nouveau?parcours=dirigeant'

      sign_in_section = response.parsed_body.at_css('.fr-connect-group')

      expect(sign_in_section.at_css('h2 + #wallet_registry_refusal + #wallet_registry_answer')).to be_present
      expect(sign_in_section.at_css('#wallet_registry_refusal h3.fr-alert__title')).to be_present
    end

    it 'lets them change their answer in the eligibility tree' do
      get '/formulaires/registre-wallet/demande/nouveau?parcours=dirigeant'

      expect(response.parsed_body.at_css('#wallet_registry_change_answer')['href']).to eq('/demandes/registre_wallet/nouveau?changer_de_reponse=true')
    end

    it 'brings them back to the registry, with their answer, after signing in again' do
      get '/formulaires/registre-wallet/demande/nouveau?parcours=dirigeant'

      expect(session[:return_to_after_sign_in]).to end_with('/formulaires/registre-wallet/demande/nouveau?parcours=dirigeant')
    end
  end

  it 'keeps the header of a signed out visitor bare, the page being the way in' do
    get agent_start_path

    header = response.parsed_body.at_css('#header')

    expect(header.text).not_to include('Se connecter')
    expect(header.css('.fr-nav__item')).to be_empty
    expect(header.at_css('.header__logo')).to be_nil
  end

  it 'gives the registry start page its own title and a list of steps for screen readers' do
    get agent_start_path

    expect(response.parsed_body.at_css('title').text).to eq('Enregistrer votre organisation au registre des parties utilisatrices du wallet - DataPass')
    expect(response.parsed_body.css('#wallet_registry_steps_list li').map(&:text)).to include('Être vérifié par le registre (5 jours ouvrés)')
    expect(response.parsed_body.at_css('#wallet_registry_steps')['aria-hidden']).to eq('true')
  end
end
