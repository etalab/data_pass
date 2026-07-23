Alors("je suis sur l'espace instruction") do
  expect(page).to have_current_path(/instruction/)
end

Quand('je me rends sur la liste des formulaires') do
  visit instruction_authorization_definitions_path
end

Quand('je me rends sur le formulaire {string}') do |definition_name|
  definition = find_authorization_definition_from_name(definition_name)
  visit instruction_authorization_definition_path(definition.id)
end

Alors('le lien retour mène vers la liste des formulaires') do
  expect(page).to have_link(href: instruction_authorization_definitions_path)
end

Quand('je me rends sur la liste des cas d\'usage de {string}') do |definition_name|
  definition = find_authorization_definition_from_name(definition_name)
  visit instruction_authorization_definition_forms_path(definition.id)
end

Quand('je me rends sur la page des étapes du formulaire {string}') do |definition_name|
  definition = find_authorization_definition_from_name(definition_name)
  visit instruction_authorization_definition_blocks_path(definition.id)
end

Alors('le lien retour mène vers le formulaire {string}') do |definition_name|
  definition = find_authorization_definition_from_name(definition_name)
  expect(page).to have_link(href: instruction_authorization_definition_path(definition.id))
end

Alors('le formulaire {string} affiche {int} demande(s) validée(s) et {int} demande(s) en cours') do |name, validated_count, submitted_count|
  definition = find_authorization_definition_from_name(name)

  within(css_id(definition)) do
    counts = all('.authorization-definition-card-count').map(&:text)
    expect(counts).to eq([validated_count.to_s, submitted_count.to_s])
  end
end

Alors('la page contient le nombre de cas d\'usage de {string}') do |definition_name|
  definition = find_authorization_definition_from_name(definition_name)
  count = definition.available_forms.size
  expect(page).to have_css('.definitions-search-count', text: /\b#{count}\b/)
end

Alors('le cas d\'usage {string} affiche {int} demande(s) validée(s) et {int} demande(s) en cours') do |form_name, validated_count, submitted_count|
  within('.fr-card', text: form_name) do
    counts = all('.authorization-definition-card-count').map(&:text)
    expect(counts).to eq([validated_count.to_s, submitted_count.to_s])
  end
end
