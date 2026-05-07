Sachantque("un type d'habilitation {string} existe") do |name|
  data_provider = DataProvider.first || FactoryBot.create(:data_provider)
  FactoryBot.create(:habilitation_type, name:, data_provider:)
end

Sachantque("un type d'habilitation {string} avec des demandes liées existe") do |name|
  data_provider = DataProvider.first || FactoryBot.create(:data_provider)
  habilitation_type = FactoryBot.create(:habilitation_type, name:, data_provider:)
  FactoryBot.create(
    :authorization_request,
    type: habilitation_type.authorization_request_type
  )
end

Sachantque("un type d'habilitation {string} expose le bloc {string}") do |name, block_name|
  data_provider = DataProvider.first || FactoryBot.create(:data_provider)
  FactoryBot.create(
    :habilitation_type,
    name:,
    data_provider:,
    cgu_link: 'https://example.org/cgu',
    blocks: [
      { 'name' => 'basic_infos' },
      { 'name' => block_name },
      { 'name' => 'contacts' },
    ],
    contact_types: ['contact_technique'],
  )
end

Sachantque("un type d'habilitation {string} avec des demandes liées et des scopes existe") do |name|
  data_provider = DataProvider.first || FactoryBot.create(:data_provider)
  habilitation_type = FactoryBot.create(
    :habilitation_type,
    name:,
    data_provider:,
    blocks: [{ 'name' => 'basic_infos' }, { 'name' => 'scopes' }],
    scopes: [{ 'name' => 'Revenu fiscal', 'value' => 'rfr', 'group' => 'Revenus' }]
  )
  FactoryBot.create(
    :authorization_request,
    type: habilitation_type.authorization_request_type
  )
end

Quand('je choisis le type {string}') do |kind|
  choose kind, allow_label_click: true
end

Quand('je remplis le scope {int} avec nom {string} valeur {string} groupe {string}') do |index, name, value, group|
  rows = all('.nested-fields')
  row = rows[index - 1]
  inputs = row.all('input.fr-input')
  inputs[0].fill_in with: name
  inputs[1].fill_in with: value
  inputs[2].fill_in with: group
end

Alors('le champ {string} est désactivé') do |label|
  expect(page).to have_field(label, disabled: true)
end

Alors('le champ radio {string} est désactivé') do |label|
  expect(page).to have_field(label, disabled: true, visible: :all)
end

Alors('le champ du scope {int} {string} est désactivé') do |index, field|
  expect(page).to have_css("#scope-#{index - 1}-#{field}[disabled]")
end

Alors('le scope {int} a pour nom {string}') do |index, name|
  expect(page).to have_css("#scope-#{index - 1}-name[value='#{name}']")
end
