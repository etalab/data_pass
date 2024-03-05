class AuthorizationRequestsController < AuthenticatedUserController
  helper AuthorizationRequestsHelpers

  allow_unauthenticated_access only: [:show]

  def index
    @authorization_definitions = AuthorizationDefinition.indexable
  end

  def new
    @authorization_definition = AuthorizationDefinition.find(id_sanitized)
  end

  def show
    @authorization_request = AuthorizationRequest.find(params[:id])

    if user_signed_in?
      authorize @authorization_request
    redirect_to authorization_request_form_path(form_uid: @authorization_request.form_uid, id: @authorization_request.id)
    else
      @authorization_definition = @authorization_request.definition
      render 'pages/home'
    end
  rescue Pundit::NotAuthorizedError
    redirect_to summary_authorization_request_form_path(form_uid: @authorization_request.form.uid, id: @authorization_request.id)
  end

  private

  def id_sanitized
    params[:id].underscore
  end
end
