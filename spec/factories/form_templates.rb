FactoryBot.define do
  factory :form_template do
    habilitation_type
    sequence(:name) { |n| "Template #{n}" }
    description { 'Un template de test' }
    introduction { nil }
    use_case { nil }
    default { false }
    public { true }
    startable_by_applicant { true }
    single_page_view { false }
    steps { [{ 'name' => 'basic_infos' }] }
    static_blocks { [] }
    scopes_config { {} }
    initialize_with { {} }
  end
end
