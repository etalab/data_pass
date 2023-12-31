Quand("j'ai déjà une demande d'habilitation {string} en cours") do |string|
  FactoryBot.create(
    :authorization_request,
    find_factory_trait_from_name(string),
    applicant: current_user,
  )
end

Quand("je démarre une nouvelle demande d'habilitation {string}") do |string|
  visit new_authorization_request_path(id: find_authorization_definition_from_name(string).id)
end

Quand('je clique sur {string} pour le formulaire {string}') do |cta_name, form_name|
  form_start_block = find('li', text: form_name)

  within(form_start_block) do
    click_link_or_button(cta_name)
  end
end

Quand('je remplis les informations du contact {string} avec :') do |string, table|
  contact_title_node = find('h3', text: string)
  contact_node = contact_title_node.find(:xpath, '..')

  within(contact_node) do
    table.hashes[0].each do |field, value|
      fill_in field, with: value
    end
  end
end

Quand("je clique sur {string} pour l'habilitation {string}") do |cta_name, habilitation_name|
  click_link cta_name, href: new_authorization_request_path(id: find_authorization_definition_from_name(habilitation_name).id.dasherize) # rubocop:disable Capybara/ClickLinkOrButtonStyle
end

Alors("il n'y a pas le bouton {string} pour l'habilitation {string}") do |text, habilitation_name|
  within(css_id(find_authorization_definition_from_name(habilitation_name))) do
    expect(page).to have_no_content(text)
  end
end

# https://rubular.com/r/Vg8QOMkfLtrxhh
Quand(/je me rends sur une demande d'habilitation "([^"]+)"(?: (?:en|à))? ?(.+)?/) do |type, status|
  if current_user.instructor?
    authorization_request = create_authorization_requests_with_status(type, status, 1).first

    visit instruction_authorization_request_path(authorization_request)
  else
    authorization_request = create_authorization_requests_with_status(type, status, 1, current_user).first

    visit authorization_request_path(authorization_request)
  end
end

# https://rubular.com/r/AiBmvod6e8ssvO
Quand(/(j'ai|il y a) (\d+) demandes? d'habilitation "([^"]+)" ?(?:en )?(.+)?/) do |who, count, type, status|
  applicant = who == 'j\'ai' ? current_user : nil
  create_authorization_requests_with_status(type, status, count, applicant)
end

# https://rubular.com/r/dRUFmK5dzDpjJv
Alors(/je vois (\d+) demandes? d'habilitation(?: "([^"]+)")?(?:(?: en)? (.+))?/) do |count, type, status|
  if type.present?
    expect(page).to have_css('.authorization-request-definition-name', text: type, count:)
  else
    expect(page).to have_css('.authorization-request', count:)
  end

  if status.present?
    state = extract_state_from_french_status(status)

    expect(page).to have_css('.authorization-request-state', text: I18n.t("authorization_request.status.#{state}"), count:) if status.present?
  end
end

Quand("j'adhère aux conditions générales") do
  steps %(
    Quand je coche "conditions générales d'utilisation"
    Quand je coche "Je confirme que le délégué à la protection des données de mon organisation est informé de ma demande."
  )
end

Quand('je renseigne les infos de bases du projet') do
  steps %(
    * je remplis "Nom du projet" avec "Conquérir le monde"
    * je remplis "Description du projet" avec "Comment chaque soir"
  )
end

Quand('je renseigne les infos concernant les données personnelles') do
  steps %(
    * je remplis "Destinataire des données" avec "Minus et Cortex"
    * je remplis "Durée de conservation des données en mois" avec "6"
  )
end

Quand('je renseigne le cadre légal') do
  steps %(
    * je remplis "Précisez la nature et les références du texte vous autorisant à traiter les données" avec "Article 42"
    * je remplis "URL du texte relatif au traitement" avec "https://legifrance.gouv.fr/affichCodeArticle.do?idArticle=LEGIARTI000006430983&cidTexte=LEGITEXT000006070721"
  )
end

Quand('je renseigne les informations des contacts RGPD') do
  steps %(
    * je remplis les informations du contact "Responsable de traitement" avec :
      | Nom    | Prénom | Email               | Téléphone   | Fonction                  |
      | Dupont | Jean   | dupont.jean@gouv.fr | 0836656560  | Responsable de traitement |
    * je remplis les informations du contact "Délégué à la protection des données" avec :
      | Nom    | Prénom  | Email                  | Téléphone   | Fonction    |
      | Dupont | Jacques | dupont.jacques@gouv.fr | 08366565601 | Délégué     |
  )
end
