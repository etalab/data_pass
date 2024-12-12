class AuthorizationRequestFormConfigurations < AbstractYAMLConfiguration
  def files
    Dir[Rails.root.join('config/authorization_request_forms/*.y*ml').to_s]
  end
end
