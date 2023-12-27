class AuthorizationRequestsController < AuthenticatedUserController
  def index
    @authorization_definitions = AuthorizationDefinition.indexable
  end

  def new
    authorization_definition = AuthorizationDefinition.find(params[:id])

    raise 'Not implemented' unless authorization_definition.available_forms.one?

    redirect_to new_authorization_request_form_path(form_uid: authorization_definition.available_forms.first.uid)
  end
end
