RSpec.describe 'Sign in block of the unauthenticated starting page' do
  def sign_in_forms
    response.parsed_body.css('form[action^="/auth/"]')
  end

  it 'adds the executive button and the return path for the wallet registry' do
    get '/formulaires/registre-wallet/demande/nouveau'

    expect(response.body).to include('Bienvenue sur DataPass !', 'login_pro_connect', 'wallet_registry_sign_in_executive')
    expect(sign_in_forms.map { |form| form.at_css('input[name="return_to"]')&.[]('value') }).to all(eq('/formulaires/registre-wallet/demande/nouveau'))
  end

  it 'keeps the usual ProConnect button alone for any other form' do
    get '/formulaires/api-entreprise/demande/nouveau'

    expect(response.body).to include('Bienvenue sur DataPass !', 'login_pro_connect')
    expect(response.body).not_to include('wallet_registry_sign_in_executive', 'wallet_registry_refusal')
    expect(sign_in_forms.size).to eq(1)
    expect(sign_in_forms.first.at_css('input[name="return_to"]')).to be_nil
  end

  it 'hides the executive button while ProConnect dirigeant is off' do
    allow(FeatureFlag).to receive(:enabled?).and_call_original
    allow(FeatureFlag).to receive(:enabled?).with(:proconnect_dirigeant).and_return(false)

    get '/formulaires/registre-wallet/demande/nouveau'

    expect(response.body).to include('login_pro_connect')
    expect(response.body).not_to include('wallet_registry_sign_in_executive')
  end

  it 'does not point a private company to the hidden executive button' do
    allow(FeatureFlag).to receive(:enabled?).and_call_original
    allow(FeatureFlag).to receive(:enabled?).with(:proconnect_dirigeant).and_return(false)
    user = create(:user, skip_organization_creation: true)
    user.add_to_organization(create(:organization, siret: '32816124500027'), current: true, verified: true)
    sign_in(user)

    get '/formulaires/registre-wallet/demande/nouveau'

    expect(response.parsed_body.at_css('#wallet_registry_refusal').text).to include('ne peuvent pas encore s’enregistrer en ligne')
    expect(response.body).not_to include('Me connecter avec ProConnect dirigeant')
  end

  it 'shows the refusal in the sign in section, under its title' do
    user = create(:user, skip_organization_creation: true)
    user.add_to_organization(create(:organization, siret: '32816124500027'), current: true, verified: true)
    sign_in(user)

    get '/formulaires/registre-wallet/demande/nouveau'

    sign_in_section = response.parsed_body.at_css('.fr-connect-group')

    expect(sign_in_section.at_css('h2 + #wallet_registry_refusal')).to be_present
    expect(sign_in_section.at_css('#wallet_registry_refusal h3.fr-alert__title')).to be_present
  end

  it 'keeps the header of a signed out visitor bare, the page being the way in' do
    get '/formulaires/registre-wallet/demande/nouveau'

    header = response.parsed_body.at_css('#header')

    expect(header.text).not_to include('Se connecter')
    expect(header.css('.fr-nav__item')).to be_empty
    expect(header.at_css('.header__logo')).to be_nil
  end

  it 'brings a refused signed in applicant back to the registry after signing in again' do
    user = create(:user, skip_organization_creation: true)
    user.add_to_organization(create(:organization, siret: '32816124500027'), current: true, verified: true)
    sign_in(user)

    get '/formulaires/registre-wallet/demande/nouveau'

    expect(session[:return_to_after_sign_in]).to end_with('/formulaires/registre-wallet/demande/nouveau')
  end

  it 'gives the registry start page its own title and a list of steps for screen readers' do
    get '/formulaires/registre-wallet/demande/nouveau'

    expect(response.parsed_body.at_css('title').text).to eq('Enregistrer votre organisation au registre des parties utilisatrices du wallet - DataPass')
    expect(response.parsed_body.css('#wallet_registry_steps_list li').map(&:text)).to include('Être vérifié par le registre (5 jours ouvrés)')
    expect(response.parsed_body.at_css('#wallet_registry_steps')['aria-hidden']).to eq('true')
  end
end
