Sachantque("un type d'habilitation {string} existe") do |name|
  data_provider = DataProvider.first || FactoryBot.create(:data_provider)
  FactoryBot.create(:habilitation_type, name:, data_provider:)
end

Sachantque('un fournisseur de données {string} existe') do |name|
  FactoryBot.create(:data_provider, name:)
end

Quand('je choisis le type {string}') do |kind|
  choose kind, allow_label_click: true
end
