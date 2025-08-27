Quand("il existe une demande d'habilitation {string} intitulée {string}") do |authorization_request_kind, authorization_request_name|
  FactoryBot.create(
    :authorization_request,
    find_factory_trait_from_name(authorization_request_kind),
    intitule: authorization_request_name,
  )
end

Quand('je veux remplir une demande pour {string} via le formulaire {string}') do |authorization_request_name, authorization_request_form_name|
  authorization_request_forms = AuthorizationRequestForm.where(
    name: authorization_request_form_name,
    authorization_request_class: find_authorization_request_class_from_name(authorization_request_name),
  ).select do |authorization_request_form|
    authorization_request_form.service_provider.blank?
  end

  raise "More than one form found for #{authorization_request_name} and #{authorization_request_form_name}" if authorization_request_forms.many?

  visit new_authorization_request_form_path(form_uid: authorization_request_forms.first.uid)
end

Quand('je veux remplir une demande pour {string} via le formulaire {string} à l\'étape {string}') do |authorization_request_name, authorization_request_form_name, stage|
  authorization_request_forms = AuthorizationRequestForm.where(
    name: authorization_request_form_name,
    authorization_request_class: find_authorization_request_class_from_name(authorization_request_name, extract_stage_type(stage)),
  )

  raise "More than one form found for #{authorization_request_name} and #{authorization_request_form_name}" if authorization_request_forms.many?

  visit new_authorization_request_form_path(form_uid: authorization_request_forms.first.uid)
end

Quand('je veux remplir une demande pour {string} via le formulaire {string} de l\'éditeur {string}') do |authorization_request_name, authorization_request_form_name, service_provider_name|
  authorization_request_forms = AuthorizationRequestForm.where(
    name: authorization_request_form_name,
    authorization_request_class: find_authorization_request_class_from_name(authorization_request_name),
  ).select do |form|
    form.service_provider.present? &&
      form.service_provider.name == service_provider_name
  end

  raise "More than one form found for #{authorization_request_name}, #{authorization_request_form_name} and #{service_provider_name}" if authorization_request_forms.many?

  visit new_authorization_request_form_path(form_uid: authorization_request_forms.first.uid)
end

Quand('je veux remplir une demande pour {string}') do |authorization_request_name|
  visit new_authorization_request_path(definition_id: find_authorization_definition_from_name(authorization_request_name).id)
end

Quand("je démarre une nouvelle demande d'habilitation {string} à l'étape {string}") do |name, stage|
  authorization_definition = find_authorization_definition_from_name(name, extract_stage_type(stage))

  if authorization_definition.available_forms.one?
    visit start_authorization_request_forms_path(form_uid: authorization_definition.available_forms.first.uid)
  else
    visit new_authorization_request_path(definition_id: find_authorization_definition_from_name(name).id)
  end
end

Quand("je démarre une nouvelle demande d'habilitation {string}") do |name|
  authorization_definition = find_authorization_definition_from_name(name, nil)

  if authorization_definition.available_forms.one?
    visit start_authorization_request_forms_path(form_uid: authorization_definition.available_forms.first.uid)
  else
    visit new_authorization_request_path(definition_id: find_authorization_definition_from_name(name).id)
  end
end

Quand("je démarre une nouvelle demande d'habilitation {string} avec le paramètre {string} égal à {string}") do |string, key, value|
  visit new_authorization_request_path(definition_id: find_authorization_definition_from_name(string).id, key => value)
end

Quand('je remplis les informations du contact {string} avec :') do |string, table|
  contact_title_node = find('h6', text: string)
  contact_node = contact_title_node.find(:xpath, '../..')

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
  click_link cta_name, href: new_authorization_request_path(definition_id: find_authorization_definition_from_name(habilitation_name).id.dasherize)
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
  expect(page).to have_xpath('//*[starts-with(@id, "summary_authorization")]')
end

Alors("il n'y a pas de formulaire en mode résumé") do
  expect(page).to have_no_xpath('//*[starts-with(@id, "summary_authorization")]')
end

Quand('je me rends sur cette demande d\'habilitation') do
  authorization_request = @authorization_request || AuthorizationRequest.last

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

# https://rubular.com/r/UD2mV5frl1q1oX
Quand(/(j'ai|il y a|mon organisation a) (\d+) demandes? d'habilitation "([^"]+)" ?(?:via le formulaire "([^"]+)")? ?(?:à l'étape "([^"]+)")? ?(?:en )?(.+)?/) do |who, count, type, form, stage, status| # rubocop:disable Metrics/ParameterLists
  applicant = case who
              when 'j\'ai'
                current_user
              when 'mon organisation a'
                user = create(:user)
                user.add_to_organization(current_user.current_organization, current: true)
                user
              end

  create_authorization_requests_with_status(type, status, count, stage, form, applicant:)
end

Quand("cette dernière demande d'habilitation s'appelait {string}") do |intitule|
  last_authorization_request = AuthorizationRequest.last
  last_authorization_request.intitule = intitule
  last_authorization_request.save
end

Quand(/je suis mentionné dans (\d+) demandes? d'habilitation "([^"]+)" en tant que "([^"]+)"/) do |count, type, role_humanized|
  role = role_humanized.parameterize.underscore
  foreign_user = create(:user)
  options = {
    "#{role}_email": current_user.email,
    applicant: foreign_user,
    organization: foreign_user.current_organization,
  }

  create_authorization_requests_with_status(type, 'soumise', count, nil, nil, options)
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

Alors("l'utilisateur {string} possède une demande d'habilitation {string}") do |email, definition_name|
  user = User.find_by(email:)

  user_session(user) do
    visit dashboard_path
    expect(page).to have_css('.authorization-request-definition-name', text: definition_name)
  end
end

Quand("un instructeur a révoqué la demande d'habilitation") do
  authorization_request = AuthorizationRequest.last
  instructor = create_instructor(authorization_request.definition.name)

  using_user_session(instructor) do
    visit instruction_authorization_request_path(authorization_request)

    click_on 'Révoquer'

    fill_in 'Indiquez les motifs de révocation', with: 'Je révoque cette demande pour des raisons de sécurité'

    click_on 'Révoquer'
  end
end

Quand("un instructeur a validé la demande d'habilitation") do
  authorization_request = AuthorizationRequest.last
  instructor = create_instructor(authorization_request.definition.id)
  instructor.update!(roles: AuthorizationDefinition.all.map { |definition| "#{definition.id}:instructor" })
  ApproveAuthorizationRequest.call(authorization_request: authorization_request, user: instructor)
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

Quand('cette demande a été {string} avec le message {string}') do |status, message|
  authorization_request = AuthorizationRequest.last
  user = User.last

  organizer = case extract_state_from_french_status(status)
              when 'changes_requested'
                params = attributes_for(:instructor_modification_request).merge(reason: message)
                RequestChangesOnAuthorizationRequest.call(
                  authorization_request: authorization_request,
                  user: user,
                  instructor_modification_request_params: params
                )
              when 'rejected'
                RefuseAuthorizationRequest.call(
                  authorization_request: authorization_request,
                  user: user,
                  rejection_reason: message
                )
              else
                raise "Status with message not implemented for: #{state}"
              end

  raise 'Organizer failed' unless organizer.success?
end

Quand('Je joins une maquette au projet {string}') do |authorization_definition_name|
  authorization_definition_id = find_authorization_definition_from_name(authorization_definition_name).id
  attach_file("authorization_request_#{authorization_definition_id}_maquette_projet",
    [
      Rails.root.join('spec/fixtures/dummy.pdf')
    ])
end

Quand('je joins 2 documents au cadre juridique du projet {string}') do |authorization_definition_name|
  authorization_definition_id = find_authorization_definition_from_name(authorization_definition_name).id
  attach_file("authorization_request_#{authorization_definition_id}_cadre_juridique_document",
    [
      Rails.root.join('spec/fixtures/dummy.pdf'),
      Rails.root.join('spec/fixtures/another_dummy.pdf')
    ])
end

Quand('cette habilitation a une pièce jointe {string}') do |safety_state|
  attachment = AuthorizationRequest.last.maquette_projet.attach([Rails.root.join('spec/fixtures/dummy.pdf')]).first

  MalwareScan.create!(sha256: SecureRandom.hex(32), attachment:, safety_state:)
end

Alors('un scan antivirus est lancé') do
  malware_scan_jobs = ActiveJob::Base.queue_adapter.enqueued_jobs.select do |job|
    job['job_class'] == 'MalwareScanJob' && job['arguments'].first.is_a?(Integer)
  end

  expect(malware_scan_jobs.count).to eq(1)
end

Quand("j'adhère aux conditions générales") do
  steps %(
    Quand je coche "conditions générales d'utilisation"
  )

  authorization_request = @authorization_request || AuthorizationRequest.last
  unless authorization_request.skip_data_protection_officer_informed_check_box?
    steps %(
      Quand je coche "Je confirme que le délégué à la protection des données de mon organisation est informé de ma demande."
    )
  end
end

Quand('je renseigne les infos de bases du projet') do
  steps %(
    * je remplis "Nom du projet" avec "Conquérir le monde"
    * je remplis "Description du projet" avec "Comment chaque soir"
  )
end

Quand('je renseigne les infos logiciel du projet') do
  steps %(
    * je remplis "Nom du logiciel" avec "Le logiciel qui conquiert le monde"
    * je remplis "Description du flux opérationnel" avec "Comment chaque matin"
    * je remplis "Date de mise en production prévue" avec "25/06/2025"
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
    * je remplis "URL du texte relatif au traitement" avec "https://legal.fr/cadre"
  )
end

Quand('je renseigne la catégorie FranceConnect Eidas') do
  find('input[value="eidas_2"]').choose
end

Quand("je renseigne l'homologation de sécurité") do
  steps %(
    * je remplis "Nom de l’autorité d’homologation ou du signataire du questionnaire de sécurité" avec "Josiane Homologation"
    * je remplis "Fonction de l’autorité d’homologation ou du signataire du questionnaire de sécurité" avec "Représentant de l'autorité d'homologation des joints d'étanchéité de conduits d'évacuation de climatiseurs de morgue"
    * je remplis "Date de début d’homologation ou de signature du questionnaire de sécurité" avec "2025-05-22"
    * je remplis "Date de fin d’homologation" avec "2050-05-22"
    * je remplis "La décision d’homologation ou le questionnaire de sécurité" avec le fichier "spec/fixtures/dummy.pdf"
  )
end

Quand('je renseigne la recette fonctionnelle') do
  steps %(
    * je coche "J’atteste avoir réalisé une recette fonctionnelle et qualifié mon téléservice."
  )
end

Quand('je renseigne la volumétrie') do
  find_field('Quelle limitation de débit souhaitez-vous pour votre téléservice ?').all('option').find { |option| option.value.present? }.select_option
end

Quand('je renseigne les informations du contact technique') do
  steps %(
    * je remplis les informations du contact "Contact technique" avec :
      | Nom    | Prénom  | Email               | Téléphone   | Fonction    |
      | Dupont | Marc    | dupont.marc@gouv.fr | 0136656565 | Technique   |
  )
end

Quand('je renseigne les informations du contact métier') do
  steps %(
    * je remplis les informations du contact "Contact métier" avec :
      | Nom    | Prénom  | Email                | Téléphone   | Fonction    |
      | Dupont | Louis   | dupont.louis@gouv.fr | 0236656565 | Métier      |
  )
end

Quand('je renseigne les informations des contacts RGPD') do
  steps %(
    * je renseigne les informations du délégué à la protection des données
    * je remplis les informations du contact "Responsable de traitement" avec :
      | Nom    | Prénom | Email               | Téléphone   | Fonction                  |
      | Dupont | Jean   | dupont.jean@gouv.fr | 0336656565  | Responsable de traitement |
  )
end

Quand('je renseigne les informations du délégué à la protection des données') do
  steps %(
    * je remplis les informations du contact "Délégué à la protection des données" avec :
      | Nom    | Prénom  | Email                  | Téléphone   | Fonction    |
      | Dupont | Jacques | dupont.jacques@gouv.fr | 0436656565 | Délégué     |
  )
end

Quand("j'enregistre et continue vers le résumé") do
  steps %(
    * je clique sur "Enregistrer et continuer vers le résumé"
  )
end

Quand('il existe un instructeur pour cette demande d\'habilitation') do
  definition = AuthorizationRequest.last.definition

  create_instructor(definition.name) unless definition.instructors.any?
end

Alors('un webhook avec l\'évènement {string} est envoyé') do |event_name|
  authorization_request = AuthorizationRequest.first

  webhook_job = ActiveJob::Base.queue_adapter.enqueued_jobs.find do |job|
    next unless job['job_class'] == 'DeliverAuthorizationRequestWebhookJob'

    JSON.parse(job['arguments'][1])['event'] == event_name
  end

  webhook_job_arg = [authorization_request.definition.id, an_instance_of(String), authorization_request.id]

  expect(webhook_job).not_to be_nil

  expect(webhook_job['arguments']).to match(webhook_job_arg)
end

# https://rubular.com/r/eAlfvtPiXB46Ec
Quand(/je me rends sur une demande d'habilitation "([^"]+)"(?: de l'organisation "([^"]+)")?(?: (?:en|à))? ?(.+)?/) do |type, organization_name, status|
  attributes = {}
  attributes[:organization] = find_or_create_organization_by_name(organization_name) if organization_name.present?

  if current_user.instructor?
    authorization_request = create_authorization_requests_with_status(type, status, 1, nil, nil, attributes).first

    visit instruction_authorization_request_path(authorization_request)
  else
    attributes[:applicant] = current_user if attributes[:organization].blank?
    authorization_request = create_authorization_requests_with_status(type, status, 1, nil, nil, attributes).first

    visit authorization_request_path(authorization_request)
  end
end

Quand('je me rends sur la dernière demande à instruire') do
  visit instruction_authorization_request_path(AuthorizationRequest.last)
end

Quand('je me rends sur la dernière demande') do
  visit authorization_request_path(AuthorizationRequest.last)
end

Quand('je me rends sur la dernière demande {string}') do |kind|
  authorization_definition = find_authorization_definition_from_name(kind)
  authorization_request = AuthorizationRequest.where(type: authorization_definition.authorization_request_class.to_s).last

  visit authorization_request_path(authorization_request)
end

# https://rubular.com/r/dRUFmK5dzDpjJv
Alors(/je vois (\d+) habilitation(?: "([^"]+)")?(?:(?: en)? (.+))?/) do |count, type, status|
  if type.present?
    expect(page).to have_css('.authorization-request-definition-name', text: type, count:)
  else
    expect(page).to have_css('.authorization', count:)
  end

  if status.present?
    state = extract_state_from_french_status(status)

    expect(page).to have_css('.authorization-request-state', text: I18n.t("authorization_request.status.#{state}"), count:)
  end
end

Quand('je visite sa page publique') do
  authorization_request = AuthorizationRequest.last

  visit public_authorization_request_path(authorization_request.public_id)
end

Sachant('{string} appartient à mon organisation') do |email|
  current_user = User.find_by(email: @current_user_email)

  user = User.find_or_create_by(email:)
  add_current_organization_to_user(user, current_user.current_organization)

  user.save!
end

Sachant('{string} appartient à une autre organisation') do |email|
  another_organization = FactoryBot.create(:organization)

  user = User.find_or_create_by(email:)
  add_current_organization_to_user(user, another_organization)
end

Quand(%r{cette demande a déjà été validée le (\d{1,2}/\d{2}/\d{4})}) do |date_string|
  date = Date.parse(date_string)
  authorization_request = AuthorizationRequest.last

  organizer = ApproveAuthorizationRequest.call(authorization_request:, user: User.first)

  organizer.authorization.update!(
    slug: date.strftime('%d-%m-%Y'),
    created_at: date,
  )
end

Quand(%r{je me rends sur l'habilitation validée(?: du (\d{1,2}/\d{2}/\d{4}))?}) do |date_string|
  authorization_request = AuthorizationRequest.last

  if date_string.present?
    date = Date.parse(date_string)
    authorization = authorization_request.authorizations.friendly.find(date.strftime('%d-%m-%Y'))
    raise "Authorization not found for #{date}" if authorization.nil?
  else
    authorization = authorization_request.latest_authorization
  end

  visit authorization_path(authorization)
end

Quand("une mise à jour globale a été effectuée sur les demandes d'habilitations {string}") do |authorization_definition_name|
  definition = find_authorization_definition_from_name(authorization_definition_name)

  AuthorizationRequest.last.update!(created_at: 2.days.ago)

  BulkAuthorizationRequestUpdate.create!(
    authorization_definition_uid: definition.id,
    reason: 'Mise à jour globale',
    application_date: 1.day.ago,
  )
end
