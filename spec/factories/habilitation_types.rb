FactoryBot.define do
  factory :habilitation_type do
    sequence(:name) { |n| "Mon API #{n}" }
    description { 'Une API de test' }
    kind { 'api' }
    data_provider
    blocks { [{ 'name' => 'basic_infos' }] }
    features { { 'messaging' => true, 'transfer' => true, 'reopening' => true } }
    scopes { [] }
    contact_types { [] }
    custom_labels { {} }
  end
end
