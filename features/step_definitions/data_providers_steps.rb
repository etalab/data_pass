Soit('un fournisseur de données {string} existe') do |name|
  FactoryBot.create(:data_provider, name:, slug: name.parameterize)
end

Soit("un fournisseur de données {string} avec des types d'habilitation liés existe") do |name|
  data_provider = FactoryBot.create(:data_provider, name:, slug: name.parameterize)
  FactoryBot.create(:habilitation_type, data_provider:)
end

Alors('le formulaire de création est visible') do
  expect(page).to have_css('#new-data-provider-form', visible: :visible)
end

Alors('le formulaire de création est masqué') do
  expect(page).to have_no_css('#new-data-provider-form', visible: :visible)
end

Alors('la liste déroulante contient {string}') do |option|
  expect(page).to have_select('habilitation_type[data_provider_id]', with_options: [option])
end

Alors('{string} est sélectionné dans la liste déroulante') do |option|
  expect(page).to have_select('habilitation_type[data_provider_id]', selected: option)
end

Quand('je clique sur {string} sans remplir le formulaire') do |label|
  find(:link_or_button, label).trigger('click')
end

Quand('je remplis le champ fournisseur {string} avec {string}') do |label, value|
  within('#new-data-provider-form') do
    fill_in label, with: value
  end
end

Alors('le formulaire affiche des erreurs de validation') do
  expect(page).to have_css('#new-data-provider-form .fr-alert--error', visible: :visible)
end

Alors("aucun fournisseur de données n'a été créé") do
  expect(DataProvider.count).to eq(0)
end
