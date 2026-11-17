Quand('je me rends sur la page de démarrage du registre wallet') do
  visit new_authorization_request_form_path(form_uid: 'registre-wallet')
end

Sachantque('le répertoire Sirene n’a pas encore renseigné mon organisation') do
  current_user!.current_organization.update!(insee_payload: nil)
end

Quand('je me rends sur la page de démarrage du registre wallet en répondant {string}') do |answer|
  profil = { 'le dirigeant d’une entreprise' => 'dirigeant', 'un agent public' => 'agent' }.fetch(answer)

  visit new_authorization_request_path(definition_id: 'registre-wallet', eligibility_confirmed: true, profil:)
end

Quand('je me rends sur l’arbre d’éligibilité du registre wallet') do
  visit new_authorization_request_path(definition_id: 'registre-wallet')
end

Quand('le répertoire Sirene renseigne mon organisation') do
  organization = current_user!.current_organization

  organization.update!(insee_payload: JSON.parse(Rails.root.join("spec/fixtures/insee/#{organization.siret}.json").read), last_insee_payload_updated_at: Time.zone.now)
end

Quand('le répertoire Sirene ne répond plus') do
  stub_request(:get, %r{^https://api.insee.fr/api-sirene/prive/3.11/siret/}).to_return(status: 503)
end

Quand('le répertoire Sirene répond de nouveau') do
  siret = current_user!.current_organization.siret

  stub_request(:get, %r{^https://api.insee.fr/api-sirene/prive/3.11/siret/#{siret}}).to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: Rails.root.join("spec/fixtures/insee/#{siret}.json").read)
end

Alors('le nom officiel saisi a été effacé de la demande') do
  expect(AuthorizationRequest::RegistreWallet.last.wallet_legal_name).to be_nil
end

Alors('aucun élément ne passe sous la barre « Précédent \\/ Suivant » quand je parcours l’étape au clavier dans une fenêtre basse') do
  page.current_window.resize_to(1280, 600)
  page.execute_script('document.activeElement.blur(); window.scrollTo(0, 0)')

  hidden_elements = Array.new(35) do
    page.driver.browser.keyboard.type(:Tab)
    page.evaluate_script(<<~JS)
      (() => {
        const element = document.activeElement
        const bar = document.querySelector('.sticky-bar')
        if (!element || element === document.body || !bar || bar.contains(element)) return null
        const box = element.getBoundingClientRect()
        const barBox = bar.getBoundingClientRect()
        return box.bottom > barBox.top && box.top < barBox.bottom ? element.id || element.textContent.trim() : null
      })()
    JS
  end

  expect(hidden_elements.compact).to be_empty
end

def login_as_applicant_of_wallet_organization(siret)
  @current_user_email = 'demandeur@gouv.fr'
  user = User.find_by(email: @current_user_email) || FactoryBot.create(:user, email: @current_user_email)
  organization = Organization.find_by(legal_entity_id: siret) || FactoryBot.create(:organization, siret:)

  add_current_organization_to_user(user, organization)
  user.save!

  mock_identity_federators(user)
end

def login_as_certified_executive_of_wallet_organization(siret)
  login_as_applicant_of_wallet_organization(siret)
  mock_proconnect_dirigeant(User.find_by(email: @current_user_email))
  @wallet_registry_certified_executive = true
end

Sachantque("je suis un demandeur d'une entreprise") do
  login_as_certified_executive_of_wallet_organization('32816124500027')
end

Sachantque("je suis un demandeur d'un établissement non diffusible") do
  login_as_certified_executive_of_wallet_organization('12345678900015')
end

Sachantque('j’ai un brouillon du registre wallet dont l’identité n’a pas pu être récupérée') do
  user = current_user!

  FactoryBot.create(:authorization_request, :registre_wallet, applicant: user, organization: user.current_organization, identity_source: 'sirene_unavailable')
end

Quand('ma certification de dirigeant expire') do
  travel(DirigeantVerificationFact::VALIDITY + 1.minute)
end

Quand('je reprends mon brouillon du registre wallet') do
  visit authorization_request_form_path(form_uid: 'registre-wallet', id: AuthorizationRequest::RegistreWallet.last.id)
end

Quand('je démarre une demande au registre wallet') do
  if @wallet_registry_certified_executive
    step 'je me rends sur la page de démarrage du registre wallet en répondant "le dirigeant d’une entreprise"'
    click_on 'S’identifier avec ProConnect'
  else
    visit new_authorization_request_form_path(form_uid: 'registre-wallet')
  end
  click_on 'Débuter ma demande'
end

Quand('je remplis ce que le registre publie') do
  fill_in 'Adresse de votre politique de confidentialité', with: 'https://www.clamart.fr/confidentialite'
  fill_in 'Adresse électronique', with: 'contact@clamart.fr'
end

def wait_for_stimulus_controller(identifier)
  connected_script = "Boolean(window.Stimulus?.getControllerForElementAndIdentifier(document.querySelector('[data-controller~=#{identifier}]'), '#{identifier}'))"

  page.document.synchronize do
    raise Capybara::ExpectationNotMet, "#{identifier} controller not connected" unless page.evaluate_script(connected_script)
  end
end

Quand('je quitte le champ {string}') do |label|
  wait_for_stimulus_controller('field-format')
  find_field(label).send_keys(:tab)
end

Quand('je remplis {string} avec {string}, je quitte le champ et le brouillon s’enregistre') do |label, value|
  wait_for_stimulus_controller('autosave')
  previous_saved_at = find_by_id('wallet-saved-at')['data-saved-at']
  fill_in label, with: value
  find_field(label).send_keys(:tab)
  expect(page).to have_css('#wallet-saved-at') { |saved_at| saved_at['data-saved-at'] != previous_saved_at }
end

Alors('le brouillon du registre wallet est archivé') do
  expect(AuthorizationRequest::RegistreWallet.last).to be_archived
end

Alors("le brouillon du registre wallet n'est pas archivé") do
  expect(AuthorizationRequest::RegistreWallet.last).not_to be_archived
end

Alors('le brouillon du registre wallet a pour site {string}') do |url|
  expect(AuthorizationRequest::RegistreWallet.last.reload.wallet_website_url.to_s).to eq(url)
end

Quand('l’INSEE renomme l’organisation en {string}') do |name|
  organization = AuthorizationRequest::RegistreWallet.last.organization
  renamed_payload = organization.insee_payload.deep_merge('etablissement' => { 'uniteLegale' => { 'denominationUniteLegale' => name } })

  organization.update!(insee_payload: renamed_payload)
  stub_request(:get, %r{^https://api.insee.fr/api-sirene/prive/3.11/siret/#{organization.siret}}).to_return(status: 200, headers: { 'Content-Type' => 'application/json' }, body: { 'etablissement' => renamed_payload['etablissement'] }.to_json)
end

Quand('je recharge la page') do
  visit current_url
end

WALLET_REQUEST_STATES = {
  'en cours de vérification' => :submitted,
  'en brouillon' => :draft,
}.freeze

Sachantque('un autre service de mon organisation, {string}, utilise l’identifiant {string}') do |state, identifier|
  organization = current_user!.current_organization
  other_applicant = FactoryBot.create(:user)
  add_current_organization_to_user(other_applicant, organization)
  other_applicant.save!

  FactoryBot.create(:authorization_request, :registre_wallet, WALLET_REQUEST_STATES.fetch(state), organization:, applicant: other_applicant, wallet_service_identifier: identifier)
end

Quand('je remplis l’étape « L’organisation » du registre wallet') do
  steps %(
    Quand je remplis ce que le registre publie
    Et je coche "n’est enregistrée comme partie utilisatrice dans aucun autre État de l’Union"
    Et je clique sur "Suivant"
  )
end

Quand('je décris le service {string} avec l’identifiant {string}') do |name, identifier|
  fill_in 'Nom du service', with: name
  fill_in 'Identifiant du service', with: identifier
  fill_in 'Description du service', with: 'Location de vélos en libre-service dans la métropole de Lyon.'
end
