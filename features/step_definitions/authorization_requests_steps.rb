Quand("j'ai déjà une demande d'habilitation {string} en cours") do |string|
  form = AuthorizationRequestForm.where(name: string).first

  FactoryBot.create(:authorization_request, type: form.authorization_request_class.to_s, applicant: current_user)
end

Quand("je démarre une nouvelle demande d'habilitation {string}") do |string|
  form_uid = AuthorizationRequestForm.where(name: string).first.uid

  visit new_authorization_request_path(form_uid:)
end

Quand('je remplis les informations du contact {string} avec :') do |string, table|
  contact_title_node = find('h3', text: string)
  contact_node = contact_title_node.find(:xpath, '..')
  contact_type = contact_node['data-contact-type']

  technical_field = {
    'Nom' => 'family_name',
    'Prénom' => 'given_name',
    'Email' => 'email',
    'Téléphone' => 'phone_number',
    'Fonction' => 'job_title',
  }

  table.hashes[0].each do |field, value|
    find("input[id$='_#{contact_type}_#{technical_field[field]}']").set(value)
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
