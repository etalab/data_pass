class MultiStagesDefinitionGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('templates', __dir__)

  argument :humanized_name, type: :string

  class_option :provider,
    type: :string,
    default: 'dinum',
    desc: "Specify the provider, if it's dgfip it will add more stuffs"

  class_option :scopes,
    type: :boolean,
    default: true,
    desc: 'Add scopes'

  def create_models_file
    template 'authorization_request_sandbox.rb.erb', "app/models/authorization_request/#{name.underscore}_sandbox.rb"
    template 'authorization_request_production.rb.erb', "app/models/authorization_request/#{name.underscore}.rb"
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

  def dgfip?
    provider == 'dgfip'
  end

  def scopes?
    options.fetch(:scopes)
  end

  def provider
    options.fetch(:provider, 'dinum').downcase
  end

  def factory_data
    <<-FACTORY_DATA

    trait :#{name.underscore}_sandbox do
      type { 'AuthorizationRequest::#{name}Sandbox' }

      form_uid { '#{name.underscore.dasherize}-sandbox' }

      with_basic_infos
      with_personal_data
      with_cadre_juridique
      #{'with_scopes' if scopes?}
    end

    trait :#{name.underscore} do
      type { 'AuthorizationRequest::#{name}' }

      form_uid { '#{name.underscore.dasherize}' }

      has_previous_authorization_validated

      with_basic_infos
      with_personal_data
      with_cadre_juridique
      #{'with_scopes' if scopes?}
      with_safety_certification
      with_operational_acceptance
      with_volumetrie
    end
    FACTORY_DATA
  end

  def end_of_factory_file
    /  end\nend/
  end
end
