class AuthorizationDefinitionConfigurations < AbstractYAMLConfiguration
  def files
    Dir[Rails.root.join('config/authorization_definitions/*.y*ml').to_s]
  end
end
