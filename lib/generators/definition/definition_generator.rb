class DefinitionGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  argument :humanized_name, type: :string

  def create_model_file
    template 'authorization_request.rb.erb', "app/models/authorization_request/#{name.underscore}.rb"
  end

  def create_definition_file
    template 'definition.yml.erb', "config/authorization_definitions/#{name.underscore}.yml"
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
