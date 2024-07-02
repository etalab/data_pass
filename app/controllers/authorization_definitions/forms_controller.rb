class AuthorizationDefinitions::FormsController < AuthenticatedUserController
  def index
    @authorization_definition = AuthorizationDefinition.find(params[:authorization_definition_id])
  end

  private

  def layout_name
    'authorization_request'
  end
end
