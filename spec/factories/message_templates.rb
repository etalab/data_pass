# rubocop:disable Style/FormatStringToken
FactoryBot.define do
  factory :message_template do
    sequence(:title) { |n| "Template #{n}" }
    authorization_definition_uid { 'api_entreprise' }
    template_type { :refusal }
    content { 'Votre demande %{demande_intitule} est disponible ici : %{demande_url}' }
  end
end
# rubocop:enable Style/FormatStringToken
