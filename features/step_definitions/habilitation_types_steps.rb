Sachantque("un type d'habilitation {string} existe") do |name|
  data_provider = DataProvider.first || FactoryBot.create(:data_provider)
  FactoryBot.create(:habilitation_type, name:, data_provider:)
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
