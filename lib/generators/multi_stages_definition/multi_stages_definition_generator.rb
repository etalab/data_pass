class MultiStagesDefinitionGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  argument :humanized_name, type: :string

  class_option :provider,
    type: :string,
    default: 'dinum',
    desc: "Specify the provider, if it's dgfip it will add more stuffs"

  def create_models_file
    template 'authorization_request_sandbox.rb.erb', "app/models/authorization_request/#{name.underscore}_sandbox.rb"
    template 'authorization_request_production.rb.erb', "app/models/authorization_request/#{name.underscore}.rb"
  end

  def insert_definitions_infos
    append_to_file 'config/authorization_definitions.yml', definitions_data
  end

  def create_forms_file
    template 'forms.yml.erb', "config/authorization_request_forms/#{name.underscore}.yml"
  end

  def create_factory_trait
    inject_into_file 'spec/factories/authorization_requests.rb', before: end_of_factory_file do
      factory_data
    end
  end

  def create_feature_file
    template 'scenario.feature.erb', "features/habilitations/#{name.underscore}.feature"
  end

  private

  def dgfip?
    provider == 'dgfip'
  end

  def provider
    options.fetch(:provider, 'dinum').downcase
  end

  # rubocop:disable Metrics/AbcSize
  def definitions_data
    <<-YAML_DATA
  #{name.underscore}_sandbox:
    name: #{humanized_name}
    description: "FEEDME"
    provider: "#{provider}"
    kind: 'api'
    link: "https://#{name.underscore.dasherize}.gouv.fr/feedme-with-valid-url"
    cgu_link: "https://#{name.underscore.dasherize}.gouv.fr/cgu"
    access_link: "https://#{name.underscore.dasherize}.gouv.fr/tokens/%<external_provider_id>"
    public: true
    stage:
      type: sandbox
      next:
        id: #{name.underscore}
        form_id: #{name.underscore.dasherize}
    blocks:
      - name: basic_infos
      - name: personal_data
      - name: legal
      - name: scopes
      - name: contacts
    scopes: &#{name.underscore}_scopes
      - name: "Scope 1"
        value: "value_1"
        group: "Groupe"

  #{name.underscore}:
    name: #{humanized_name}
    description: "FEEDME"
    provider: "#{provider}"
    kind: 'api'
    link: "https://#{name.underscore.dasherize}.gouv.fr/feedme-with-valid-url"
    cgu_link: "https://#{name.underscore.dasherize}.gouv.fr/cgu"
    access_link: "https://#{name.underscore.dasherize}.gouv.fr/tokens/%<external_provider_id>"
    public: true
    stage:
      type: production
      previouses:
        - id: #{name.underscore}_sandbox
          form_id: #{name.underscore.dasherize}-sandbox
    blocks:
      - name: basic_infos
      - name: personal_data
      - name: legal
      - name: scopes
      - name: contacts
      - name: operational_acceptance
      - name: safety_certification
      - name: volumetrie
    scopes: *#{name.underscore}_scopes
    YAML_DATA
  end

  def factory_data
    <<-FACTORY_DATA

    trait :#{name.underscore}_sandbox do
      type { 'AuthorizationRequest::#{name}Sandbox' }

      form_uid { '#{name.underscore.dasherize}-sandbox' }

      with_basic_infos
      with_personal_data
      with_cadre_juridique
      with_scopes
    end

    trait :#{name.underscore} do
      type { 'AuthorizationRequest::#{name}' }

      form_uid { '#{name.underscore.dasherize}' }

      with_basic_infos
      with_personal_data
      with_cadre_juridique
      with_scopes
      with_safety_certification
      with_operational_acceptance
      with_volumetrie
    end
    FACTORY_DATA
  end
  # rubocop:enable Metrics/AbcSize

  def end_of_factory_file
    /  end\nend/
  end
end
