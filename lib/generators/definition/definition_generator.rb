class DefinitionGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  argument :humanized_name, type: :string

  def create_model_file
    template 'authorization_request.rb.erb', "app/models/authorization_request/#{name.underscore}.rb"
  end

  def insert_definition_infos
    append_to_file 'config/authorization_definitions.yml', definition_data
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

  def definition_data
    <<-YAML_DATA
  #{name.underscore}:
    name: #{humanized_name}
    description: "FEEDME"
    provider: "dinum"
    kind: 'api'
    link: "https://#{name.underscore.dasherize}.gouv.fr/feedme-with-valid-url"
    cgu_link: "https://#{name.underscore.dasherize}.gouv.fr/cgu"
    access_link: "https://#{name.underscore.dasherize}.gouv.fr/tokens/%<external_provider_id>"
    public: true
    blocks:
      - name: "basic_infos"
      - name: "personal_data"
      - name: "legal"
      - name: "scopes"
      - name: "contacts"
    scopes:
      - name: "Scope 1"
        value: "value_1"
        group: "Groupe"
    YAML_DATA
  end

  def factory_data
    <<-FACTORY_DATA

    trait :#{name.underscore} do
      type { 'AuthorizationRequest::#{name}' }

      form_uid { '#{name.underscore.dasherize}' }

      with_basic_infos
      with_personal_data
      with_cadre_juridique
      with_scopes
    end
    FACTORY_DATA
  end

  def end_of_factory_file
    /  end\nend/
  end
end
