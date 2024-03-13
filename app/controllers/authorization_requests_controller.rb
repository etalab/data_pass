class AuthorizationRequestsController < AuthenticatedUserController
  helper AuthorizationRequestsHelpers

  allow_unauthenticated_access only: %i[new show]

  def index
    @authorization_definitions = AuthorizationDefinition.indexable
  end

  def new
    if user_signed_in?
      @authorization_definition = AuthorizationDefinition.find(id_sanitized)
    else
      new_as_guest_user
    end
  end

  def show
    @authorization_request = AuthorizationRequest.find(params[:id])

    if user_signed_in?
      show_as_authenticated_user
    else
      show_as_guest_user
    end
  end

  private

  def show_as_authenticated_user
    authorize @authorization_request

    redirect_to authorization_request_form_path(form_uid: @authorization_request.form_uid, id: @authorization_request.id)
  rescue Pundit::NotAuthorizedError
    redirect_to summary_authorization_request_form_path(form_uid: @authorization_request.form.uid, id: @authorization_request.id)
  end

  def show_as_guest_user
    @authorization_definition = @authorization_request.definition

    save_redirect_path
    @display_provider_logo_in_header = true

    render 'pages/home'
  end

  def new_as_guest_user
    @authorization_definition = AuthorizationDefinition.find(id_sanitized)
    save_redirect_path
    @display_provider_logo_in_header = true

    render 'authorization_requests/unauthenticated_start'
  end

  def id_sanitized
    params[:id].underscore
  end
end
