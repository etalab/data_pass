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

Quand('je coche les cases de conditions générales et du délégué à la protection des données') do
  steps %(
    Quand je coche "J'ai pris connaissance des conditions générales d'utilisation et je les valide."
    Quand je coche "Je confirme que le délégué à la protection des données de mon organisation est informé de ma demande."
  )
end

Quand('je clique sur {string} pour le formulaire {string}') do |cta_name, form_name|
  form_uid = AuthorizationRequestForm.where(name: form_name).first.uid

  click_link cta_name, href: new_authorization_request_path(form_uid:)
end

# https://rubular.com/r/oBcBPVLlH2kFDl
Quand(/je me rends sur une demande d'habilitation "([^"]+)"(?: (?:en|à))? ?(\S+)?/) do |type, status|
  authorization_request = create_authorization_requests_with_status(type, status, 1).first

  visit instruction_authorization_request_path(authorization_request)
end

# https://rubular.com/r/oYVuAoQY2UZ1FZ
Quand(/il y a (\d+) demandes? d'habilitation "([^"]+)"(?: en )?(\w+)?/) do |count, type, status|
  create_authorization_requests_with_status(type, status, count)
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
