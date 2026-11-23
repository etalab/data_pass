Quand('je me rends sur la page de démarrage du registre wallet') do
  visit authorization_request_form_introduction_path(form_uid: 'registre-wallet')
end

Sachantque('le répertoire Sirene n’a pas encore renseigné mon organisation') do
  current_user!.current_organization.update!(insee_payload: nil)
end

Quand('je me rends sur la page de démarrage du registre wallet en répondant {string}') do |answer|
  parcours = { 'le dirigeant d’une entreprise' => 'dirigeant', 'un agent public' => 'agent' }.fetch(answer)

  visit new_authorization_request_path(definition_id: 'registre-wallet', eligibility_confirmed: true, parcours:)
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

Sachantque("je suis un demandeur d'un établissement non diffusible dont Sirene donne l’adresse") do
  login_as_certified_executive_of_wallet_organization('12345678900023')
end

Sachantque('j’ai un brouillon du registre wallet dont l’identité n’a pas pu être récupérée') do
  user = current_user!

  FactoryBot.create(:authorization_request, :registre_wallet, applicant: user, organization: user.current_organization, identity_source: 'sirene_unavailable')
end

Quand('ma certification de dirigeant est retirée') do
  current_user!.organizations_users.find_each { |organizations_user| organizations_user.update!(dirigeant_verified_at: nil) }
end

Quand('je reprends mon brouillon du registre wallet') do
  visit authorization_request_form_path(form_uid: 'registre-wallet', id: AuthorizationRequest::RegistreWallet.last.id)
end

Quand('je démarre une demande au registre wallet') do
  if @wallet_registry_certified_executive
    step 'je me rends sur la page de démarrage du registre wallet en répondant "le dirigeant d’une entreprise"'
    click_on 'S’identifier avec ProConnect'
  else
    visit authorization_request_form_introduction_path(form_uid: 'registre-wallet')
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

Quand('je décris le service {string} avec l’identifiant {string} sans justificatif') do |name, identifier|
  fill_in 'Nom du service', with: name
  fill_in 'Identifiant du service', with: identifier
  fill_in 'Description du service', with: 'Location de vélos en libre-service dans la métropole de Lyon.'
end

Quand('je décris le service {string} avec l’identifiant {string}') do |name, identifier|
  steps %(Quand je décris le service "#{name}" avec l’identifiant "#{identifier}" sans justificatif)
  find_field('authorization_request_registre_wallet_wallet_service_name_proof', visible: :all).set(Rails.root.join('spec/fixtures/dummy.pdf').to_s)
end

Quand('je remplis l’étape « Le service » du registre wallet') do
  steps %(
    Quand je décris le service "Vélocité Libre-service" avec l’identifiant "libre-service"
    Et je clique sur "Suivant"
  )
end

def last_wallet_intended_use_card
  all('.usage-card').last
end

Quand('j’ajoute une utilisation prévue {string}') do |name|
  count = all('.usage-card').size
  click_button 'Ajouter une utilisation prévue'
  expect(page).to have_css('.usage-card', count: count + 1)

  within(last_wallet_intended_use_card) do
    fill_in 'Nom de l’utilisation prévue', with: name
    fill_in 'Pourquoi demandez-vous ces données ?', with: 'Vérifier que vous avez plus de 18 ans avant de vous louer un vélo.'
    fill_in 'Date de début', with: Date.current.iso8601
  end
end

Quand('j’ouvre le catalogue des attestations de la dernière utilisation') do
  within(last_wallet_intended_use_card) do
    click_button 'Ajouter une attestation' if javascript?
    click_button 'Ouvrir le catalogue des attestations' unless javascript?
  end
  expect(page).to have_text('attestations dans le catalogue de la Commission')
end

Quand('je cherche {string} dans le catalogue des attestations') do |query|
  if javascript?
    within(last_wallet_intended_use_card) { fill_in 'Rechercher une attestation ou une donnée', with: query }
  else
    fill_in 'Rechercher une attestation ou une donnée', with: query
    click_button 'Rechercher'
  end
end

Quand('j’ajoute l’attestation {string} à la dernière utilisation') do |attestation|
  step 'j’ouvre le catalogue des attestations de la dernière utilisation'
  javascript? ? within(last_wallet_intended_use_card) { click_button "Ajouter #{attestation}" } : click_button("Ajouter #{attestation}")
  expect(page).to have_css('.usage-card .att-acc', text: attestation)
end

Quand('je coche les données {string} de la dernière utilisation') do |labels|
  within(last_wallet_intended_use_card) do
    labels.split(', ').each { |label| javascript? ? find(:checkbox, label, visible: :all).trigger('click') : check(label) }
  end
end

Quand('je remplis le champ {string} de la dernière utilisation avec {string}') do |label, value|
  within(last_wallet_intended_use_card) { fill_in label, with: value }
end

Quand('je remplis le champ {string} de la première utilisation avec {string}') do |label, value|
  within(first('.usage-card')) { fill_in label, with: value }
end

Quand('je clique sur {string} dans la dernière utilisation') do |label|
  within(last_wallet_intended_use_card) { click_button label, match: :first }
end

Quand('je choisis {string} comme utilisation affichée') do |name|
  select name, from: 'Utilisation prévue affichée'
end

Quand('je fais défiler la page jusqu’à la {word} utilisation') do |position|
  card = position == 'première' ? first('.usage-card') : last_wallet_intended_use_card
  page.execute_script("arguments[0].scrollIntoView({ block: 'center' })", card)
end

Quand('je donne le focus à « {word} » dans la première utilisation, sans faire défiler') do |label|
  button = within(first('.usage-card')) { find_button(label, match: :first) }
  page.execute_script('arguments[0].focus({ preventScroll: true })', button)
end

Alors('l’aperçu montre l’utilisation {string} et {string}') do |name, purpose|
  expect(page).to have_select('Utilisation prévue affichée', selected: name)
  expect(page).to have_css('.wallet-preview', visible: :visible, count: 1)
  expect(find('.wallet-preview', visible: :visible)).to have_text(purpose)
end

Quand('je confirme {string} dans la dernière utilisation') do |label|
  within(last_wallet_intended_use_card) { click_button label, exact: true }
end

Alors('le brouillon du registre wallet produit {string} au format Credential') do |vct|
  credentials = AuthorizationRequest::RegistreWallet.last.reload.wallet_intended_uses.flat_map(&:credentials)

  expect(credentials).to include(a_hash_including('format' => 'dc+sd-jwt', 'meta' => { 'vct_values' => [vct] }))
end

Alors('les politiques de confidentialité des utilisations sont {string}') do |urls|
  uses = AuthorizationRequest::RegistreWallet.last.reload.wallet_intended_uses

  expect(uses.map(&:effective_privacy_policy_url)).to eq(urls.split(', '))
end

Alors('le brouillon du registre wallet compte {int} utilisation(s) prévue(s)') do |count|
  expect(AuthorizationRequest::RegistreWallet.last.reload.wallet_intended_uses.size).to eq(count)
end

Quand('je remplis l’étape « Les utilisations prévues » du registre wallet') do
  steps %(
    Quand j’ajoute une utilisation prévue "Vérifier la majorité"
    Et j’ajoute l’attestation "Permis de conduire mobile" à la dernière utilisation
    Et je coche les données "Plus de 18 ans" de la dernière utilisation
    Et je clique sur "Suivant"
  )
end

WALLET_CONTACT_FIELDS = {
  'nom' => 'Nom',
  'prénom' => 'Prénom',
  'adresse électronique' => 'Email',
  'téléphone' => 'Téléphone',
}.freeze

def wallet_contact_block(title)
  find('h3', text: title, exact_text: true).ancestor('.wx-panel')
end

def wallet_contact_field(title, field)
  wallet_contact_block(title).find_field(WALLET_CONTACT_FIELDS.fetch(field))
end

Quand('je remplis le contact {string} avec {string}, {string}, {string} et {string}') do |title, family_name, given_name, email, phone|
  within(wallet_contact_block(title)) do
    fill_in 'Nom', with: family_name
    fill_in 'Prénom', with: given_name
    fill_in 'Email', with: email
    fill_in 'Téléphone', with: phone
  end
end

Quand('je remplis le champ {string} du contact {string} avec {string}') do |field, title, value|
  wallet_contact_field(title, field).fill_in(with: value)
end

Quand('je vide le contact {string}') do |title|
  WALLET_CONTACT_FIELDS.each_key { |field| wallet_contact_field(title, field).fill_in(with: '') }
end

Quand('je clique sur « C’est moi » dans le contact {string}') do |title|
  within(wallet_contact_block(title)) { click_button 'C’est moi' }
end

Quand('je remplis les trois contacts du registre wallet') do
  steps %(
    Quand je remplis le contact "Responsable de l’application" avec "Martin", "Camille", "camille.martin@clamart.fr" et "04 72 00 00 00"
    Et je remplis le contact "Contact technique" avec "Lefèvre", "Jules", "jules.lefevre@clamart.fr" et "+33 (0)4 72 00 00 01"
    Et je remplis le contact "Délégué à la protection des données (DPO)" avec "Durand", "Alex", "dpo@clamart.fr" et "04.72.00.00.02"
  )
end

Quand('je remplis l’étape « Les contacts » du registre wallet') do
  steps %(
    Quand je remplis les trois contacts du registre wallet
    Et je clique sur "Suivant"
  )
end

Quand('je saisis à la main mes nom, prénom et adresse électronique dans le contact {string}') do |title|
  user = current_user!

  { 'nom' => user.family_name, 'prénom' => user.given_name, 'adresse électronique' => user.email }.each do |field, value|
    wallet_contact_field(title, field).fill_in(with: value)
  end
end

Alors('le contact {string} porte mes nom, prénom et adresse électronique, sans téléphone') do |title|
  user = current_user!
  values = WALLET_CONTACT_FIELDS.keys.map { |field| wallet_contact_field(title, field).value.to_s }

  expect(values).to eq([user.family_name, user.given_name, user.email, ''].map(&:to_s))
end

Alors('le bouton « C’est moi » est proposé dans le(s) contact(s) {string}') do |titles|
  offered = all('.wx-panel').select { |panel| panel.has_button?('C’est moi', wait: false) }.map { |panel| panel.find('h3').text }

  expect(offered).to eq(titles.split(', '))
end

Sachantque('les étapes 1 à 3 de mon brouillon du registre wallet ont été vidées') do
  request = AuthorizationRequest::RegistreWallet.last
  kept_data = request.data.select { |key, _value| key.start_with?(*AuthorizationExtensions::WalletContacts::CONTACT_TYPES.map(&:to_s), 'identity_') }

  request.wallet_intended_uses.destroy_all
  request.data = kept_data
  request.save!(validate: false)
end

Alors('le brouillon du registre wallet a pour contact technique {string}') do |full_name|
  request = AuthorizationRequest::RegistreWallet.last.reload

  expect([request.wallet_technical_contact_given_name, request.wallet_technical_contact_family_name].join(' ')).to eq(full_name)
end

Alors('le(s) champ(s) {string} du contact {string} n’est/ne sont plus signalé(s) en erreur') do |fields, title|
  fields.split(', ').each do |field|
    input = wallet_contact_field(title, field)
    group = input.ancestor('.fr-input-group')

    expect(group[:class]).not_to include('fr-input-group--error')
    expect(group).to have_no_css('.fr-message--error')
    expect(input[:'aria-describedby'].to_s).not_to include('-messages')
  end
end

Alors('le champ {string} du contact {string} est signalé en erreur') do |field, title|
  group = wallet_contact_field(title, field).ancestor('.fr-input-group')

  expect(group[:class]).to include('fr-input-group--error')
  expect(group).to have_css('.fr-message--error')
end

Quand('j’arrive au récapitulatif du registre wallet') do
  steps %(
    Quand je démarre une demande au registre wallet
    Et je remplis ce que le registre publie
    Et je coche "n’est enregistrée comme partie utilisatrice dans aucun autre État de l’Union"
    Et je clique sur "Suivant"
    Et je décris le service "Vélocité Libre-service" avec l’identifiant "libre-service"
    Et je clique sur "Suivant"
    Et je remplis l’étape « Les utilisations prévues » du registre wallet
    Et je remplis l’étape « Les contacts » du registre wallet
  )
end

Quand('je coche les deux engagements du registre wallet') do
  check 'J’ai pris connaissance de la politique d’enregistrement'
  check 'Je certifie que ces informations sont exactes'
end

Quand('la description du service de mon brouillon du registre wallet est vidée') do
  authorization_request = AuthorizationRequest::RegistreWallet.last
  authorization_request.wallet_service_description = ''
  authorization_request.save!(validate: false)
end

Quand('les informations de l’organisation de mon brouillon du registre wallet sont en cours de chargement') do
  authorization_request = AuthorizationRequest::RegistreWallet.last
  authorization_request.organization.update!(insee_payload: nil)
  authorization_request.data = authorization_request.data.merge('identity_source' => IdentitySources::Sirene.pending_source)
  authorization_request.save!(validate: false)
end

Alors('la liste des étapes incomplètes précède le récapitulatif') do
  html = Nokogiri::HTML(page.html)
  ordered_ids = html.css('#wallet-incomplete-steps, .summary-block, #wallet-consents').map { |node| node['id'] || 'block' }

  expect(ordered_ids.first).to eq('wallet-incomplete-steps')
  expect(html.at_css('#wallet-incomplete-steps[autofocus]')).to be_present
end

Quand('je modifie le bloc « L’organisation » de mon brouillon du registre wallet') do
  visit edit_authorization_request_block_path(AuthorizationRequest::RegistreWallet.last, 'organisation')
end

Alors('le bouton {string} est désactivé') do |label|
  expect(page).to have_button(label, disabled: true)
end

Alors('la demande du registre wallet est en cours de vérification') do
  expect(AuthorizationRequest::RegistreWallet.last).to be_submitted
end

Alors('la demande du registre wallet est toujours un brouillon') do
  expect(AuthorizationRequest::RegistreWallet.last).to be_draft
end
