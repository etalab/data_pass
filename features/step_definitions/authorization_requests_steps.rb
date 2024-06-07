Quand("j'ai déjà une demande d'habilitation {string} en cours") do |string|
  FactoryBot.create(
    :authorization_request,
    find_factory_trait_from_name(string),
    applicant: current_user,
  )
end

Quand('je veux remplir une demande pour {string} via le formulaire {string}') do |authorization_request_name, authorization_request_form_name|
  authorization_request_forms = AuthorizationRequestForm.where(
    name: authorization_request_form_name,
    authorization_request_class: find_authorization_request_class_from_name(authorization_request_name),
  )

  raise "More than one form found for #{authorization_request_name} and #{authorization_request_form_name}" if authorization_request_forms.count > 1

  visit new_authorization_request_form_path(form_uid: authorization_request_forms.first.uid)
end

Quand('je veux remplir une demande pour {string} via le formulaire {string} de l\'éditeur {string}') do |authorization_request_name, authorization_request_form_name, editor_name|
  authorization_request_forms = AuthorizationRequestForm.where(
    name: authorization_request_form_name,
    authorization_request_class: find_authorization_request_class_from_name(authorization_request_name),
  ).select do |form|
    form.editor.name == editor_name
  end

  raise "More than one form found for #{authorization_request_name}, #{authorization_request_form_name} and #{editor_name}" if authorization_request_forms.count > 1

  visit new_authorization_request_form_path(form_uid: authorization_request_forms.first.uid)
end

Quand('je veux remplir une demande pour {string}') do |authorization_request_name|
  visit new_authorization_request_path(id: find_authorization_definition_from_name(authorization_request_name).id)
end

Quand("je démarre une nouvelle demande d'habilitation {string}") do |string|
  visit new_authorization_request_path(id: find_authorization_definition_from_name(string).id)

  click_on 'Débuter mon habilitation'
end

Quand("je démarre une nouvelle demande d'habilitation {string} avec le paramètre {string} égal à {string}") do |string, key, value|
  visit choose_authorization_request_form_path(authorization_definition_id: find_authorization_definition_from_name(string).id, key => value)
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

Quand('cette demande a été modifiée avec les informations suivantes :') do |table|
  authorization_request = AuthorizationRequest.last

  params = table.hashes.each_with_object({}) do |hash, data|
    data[hash['champ']] = hash['nouvelle valeur']
  end

  authorization_request.update!(params)
end

Quand("je clique sur {string} pour l'habilitation {string}") do |cta_name, habilitation_name|
  click_link cta_name, href: new_authorization_request_path(id: find_authorization_definition_from_name(habilitation_name).id.dasherize) # rubocop:disable Capybara/ClickLinkOrButtonStyle
end

Alors("il n'y a pas le bouton {string} pour l'habilitation {string}") do |text, habilitation_name|
  within(css_id(find_authorization_definition_from_name(habilitation_name))) do
    expect(page).to have_no_content(text)
  end
end

Alors('il y a un formulaire en plusieurs étapes') do
  expect(page).to have_css('.fr-stepper')
end

Alors('il y a un formulaire en une seule page') do
  expect(page).to have_no_css('.fr-stepper')
end

Alors('il y a un formulaire en mode résumé') do
  expect(page).to have_xpath('//*[starts-with(@id, "summary_authorization_request_")]')
end

Alors("il n'y a pas de formulaire en mode résumé") do
  expect(page).to have_no_xpath('//*[starts-with(@id, "summary_authorization_request_")]')
end

Quand('je me rends sur cette demande d\'habilitation') do
  authorization_request = AuthorizationRequest.last

  if current_user.instructor?
    visit instruction_authorization_request_path(authorization_request)
  else
    visit authorization_request_path(authorization_request)
  end
end

Quand(/je me rends via l'espace usager sur une demande d'habilitation "([^"]+)"/) do |type|
  authorization_request = create_authorization_requests_with_status(type).first

  visit authorization_request_path(authorization_request)
end

# https://rubular.com/r/0orApA5lrXMtTA
Quand(/je me rends sur une demande d'habilitation "([^"]+)"(?: de l'organisation "([^"]+)")?(?: (?:en|à))? ?(.+)?/) do |type, organization_name, status|
  attributes = {}
  attributes[:organization] = find_or_create_organization_by_name(organization_name) if organization_name.present?

  if current_user.reporter?
    authorization_request = create_authorization_requests_with_status(type, status, 1, attributes).first

    visit instruction_authorization_request_path(authorization_request)
  else
    authorization_request = create_authorization_requests_with_status(type, status, 1, attributes.merge(applicant: current_user)).first

    visit authorization_request_path(authorization_request)
  end
end

# https://rubular.com/r/t8v2hsttNnb9h3
Quand(/(j'ai|il y a|mon organisation a) (\d+) demandes? d'habilitation "([^"]+)" ?(?:en )?(.+)?/) do |who, count, type, status|
  applicant = case who
              when 'j\'ai'
                current_user
              when 'mon organisation a'
                create(:user, current_organization: current_user.current_organization)
              end

  create_authorization_requests_with_status(type, status, count, applicant:)
end

Quand(/je suis mentionné dans (\d+) demandes? d'habilitation "([^"]+)" en tant que "([^"]+)"/) do |count, type, role_humanized|
  role = role_humanized.parameterize.underscore
  foreign_user = create(:user)
  options = {
    "#{role}_email": current_user.email,
    applicant: foreign_user,
    organization: foreign_user.current_organization,
  }

  create_authorization_requests_with_status(type, 'soumise', count, options)
end

# https://rubular.com/r/dRUFmK5dzDpjJv
Alors(/je vois (\d+) demandes? d'habilitation(?: "([^"]+)")?(?:(?: en)? (.+))?/) do |count, definition_name, status|
  if definition_name.present?
    expect(page).to have_css('.authorization-request-definition-name', text: definition_name, count:)
  else
    expect(page).to have_css('.authorization-request', count:)
  end

  if status.present?
    state = extract_state_from_french_status(status)

    expect(page).to have_css('.authorization-request-state', text: I18n.t("authorization_request.status.#{state}"), count:)
  end
end

Quand('cette demande a été {string}') do |status|
  authorization_request = AuthorizationRequest.last
  user = User.last

  case extract_state_from_french_status(status)
  when 'submitted'
    organizer = SubmitAuthorizationRequest.call(authorization_request:, user:)
  when 'validated'
    organizer = ApproveAuthorizationRequest.call(authorization_request:, user:)
  when 'refused'
    organizer = RefuseAuthorizationRequest.call(authorization_request:, user:, denial_of_authorization_params: attributes_for(:denial_of_authorization))
  when 'changes_requested'
    organizer = RequestChangesOnAuthorizationRequest.call(authorization_request:, user:, instructor_modification_request_params: attributes_for(:instructor_modification_request))
  else
    raise "Unknown status: #{status}"
  end

  raise 'Organizer failed' unless organizer.success?
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

Quand('il existe un instructeur pour cette demande d\'habilitation') do
  definition = AuthorizationRequest.last.definition

  create_instructor(definition.name) unless definition.instructors.any?
end

Alors('Un webhook avec l\'évènement {string} est envoyé') do |event_name|
  authorization_request = AuthorizationRequest.first

  webhook_job = ActiveJob::Base.queue_adapter.enqueued_jobs.find do |job|
    next unless job['job_class'] == 'DeliverAuthorizationRequestWebhookJob'

    JSON.parse(job['arguments'][1])['event'] == event_name
  end

  webhook_job_arg = [authorization_request.definition.id, an_instance_of(String), authorization_request.id]

  expect(webhook_job).not_to be_nil

  expect(webhook_job['arguments']).to match(webhook_job_arg)
end

# https://rubular.com/r/0orApA5lrXMtTA
Quand(/je me rends sur une habilitation "([^"]+)"(?: de l'organisation "([^"]+)")?(?: (?:en|à))? ?(.+)?/) do |type, organization_name, status|
  attributes = {}
  attributes[:organization] = find_or_create_organization_by_name(organization_name) if organization_name.present?

  if current_user.instructor?
    authorization_request = create_authorization_requests_with_status(type, status, 1, attributes).first

    visit instruction_authorization_request_path(authorization_request)
  else
    authorization_request = create_authorization_requests_with_status(type, status, 1, attributes.merge(applicant: current_user)).first

    visit authorization_request_path(authorization_request)
  end
end

# https://rubular.com/r/dRUFmK5dzDpjJv
Alors(/je vois (\d+) habilitation(?: "([^"]+)")?(?:(?: en)? (.+))?/) do |count, type, status|
  if type.present?
    expect(page).to have_css('.authorization-request-definition-name', text: type, count:)
  else
    expect(page).to have_css('.authorization-request', count:)
  end

  if status.present?
    state = extract_state_from_french_status(status)

    expect(page).to have_css('.authorization-request-state', text: I18n.t("authorization_request.status.#{state}"), count:)
  end
end

Et('je peux voir le bouton {string} grisé et désactivé') do |string|
  expect(page).to have_css('button[disabled]', text: string)
end
