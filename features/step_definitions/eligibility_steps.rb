Quand('je me rends sur la page de démarrage d\'une demande {string}') do |api_name|
  definition_id = api_name.parameterize
  visit new_authorization_request_path(definition_id:)
end

Quand('je sélectionne {string}') do |option_label|
  label = find('label', text: option_label)
  label.click
end

Alors('je vois un lien {string}') do |link_text|
  expect(page).to have_link(link_text)
end
