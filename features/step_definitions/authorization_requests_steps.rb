Quand("j'ai déjà une demande d'habilitation {string} en cours") do |string|
  FactoryBot.create(
    :authorization_request,
    find_factory_trait_from_name(string),
    applicant: current_user,
  )
end

Quand("je démarre une nouvelle demande d'habilitation {string}") do |string|
  visit new_authorization_request_path(form_uid: find_form_from_name(string).uid)
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

Quand('je clique sur {string} pour le formulaire {string}') do |cta_name, form_name|
  form_uid = AuthorizationRequestForm.where(name: form_name).first.uid

  click_link cta_name, href: new_authorization_request_path(form_uid:)
end

Alors("il n'y a pas le bouton {string} pour le formulaire {string}") do |text, form_name|
  form = AuthorizationRequestForm.where(name: form_name).first

  within(css_id(form)) do
    expect(page).not_to have_content(text)
  end
end

# https://rubular.com/r/oBcBPVLlH2kFDl
Quand(/je me rends sur une demande d'habilitation "([^"]+)"(?: (?:en|à))? ?(\S+)?/) do |type, status|
  authorization_request = create_authorization_requests_with_status(type, status, 1).first

  visit instruction_authorization_request_path(authorization_request)
end

# https://rubular.com/r/ONkLmQtr34p3ic
Quand(/(j'ai|il y a) (\d+) demandes? d'habilitation "([^"]+)"(?: en )?(\w+)?/) do |who, count, type, status|
  applicant = who == 'j\'ai' ? current_user : nil
  create_authorization_requests_with_status(type, status, count, applicant)
end

# https://rubular.com/r/meA7pKlPwfrZs3
Alors(/je vois (\d+) demandes? d'habilitation(?: "([^"]+)")?(?:(?: en)? (\S+))?$/) do |count, type, status|
  if type.present?
    expect(page).to have_css('.authorization-request-form-name', text: type, count:)
  else
    expect(page).to have_css('.authorization-request', count:)
  end

  expect(page).to have_css('.authorization-request-state', text: status.humanize, count:) if status.present?
end

Quand("j'adhère aux conditions générales") do
  steps %(
    Quand je coche "J'ai pris connaissance des conditions générales d'utilisation et je les valide."
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
