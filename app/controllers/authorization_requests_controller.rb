class AuthorizationRequestsController < AuthenticatedUserController
  helper AuthorizationRequestsHelpers
  include SubdomainsHelper

  allow_unauthenticated_access only: %i[new show]

  before_action :find_authorization_definition, only: %i[new]
  before_action :set_facade, only: %i[new]

  def new
    if user_signed_in?
      custom_template_path = "authorization_requests/new/#{@authorization_definition.id}"

      if template_exists?(custom_template_path)
        render custom_template_path
      elsif @authorization_definition.available_forms.many?
        render 'authorization_requests/new/default', layout: 'form_introduction'
      else
        redirect_to new_authorization_request_form_path(form_uid: @authorization_definition.available_forms.first.id)
      end
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
  rescue ActiveRecord::RecordNotFound
    raise unless registered_subdomain? && registered_subdomain.id == 'hubee'

    redirect_to dashboard_path
  end

  private

  def find_authorization_definition
    @authorization_definition = AuthorizationDefinition.find(id_sanitized)
  end

  def set_facade
    klass = NewAuthorizationRequest.facade(definition_id: id_sanitized)
    @facade = klass.new(authorization_definition: @authorization_definition)
  end

  def show_as_authenticated_user
    flash.keep

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
