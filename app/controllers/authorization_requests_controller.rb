class AuthorizationRequestsController < AuthenticatedUserController
  helper AuthorizationRequestsHelpers
  include SubdomainsHelper
  include WalletRegistryAnswer

  allow_unauthenticated_access only: %i[new show]

  before_action :find_authorization_definition, only: %i[new]
  before_action :redirect_to_wallet_registry_form, only: %i[new], if: :signed_in_wallet_registry_applicant?
  before_action :set_facade, only: %i[new]
  before_action :find_eligibility_rule, only: %i[new]
  before_action :render_eligibility_check, only: %i[new], if: -> { @eligibility_rule && wallet_registry_answer_change? }

  decorates_assigned :eligibility_rule

  def new
    if user_signed_in?
      authorize @authorization_definition, :new?

      custom_template_path = "authorization_requests/new/#{@authorization_definition.id}"

      if template_exists?(custom_template_path)
        render custom_template_path
      elsif @authorization_definition.public_available_forms.many?
        render 'authorization_requests/new/default', layout: 'form_introduction'
      else
        redirect_to new_authorization_request_form_path(form_uid: @authorization_definition.public_available_forms.first.id)
      end
    else
      new_as_guest_user
    end
  rescue Pundit::NotAuthorizedError
    render_refusal
  end

  def show
    @authorization_request = AuthorizationRequest.find(params.expect(:id))

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

  def signed_in_wallet_registry_applicant?
    user_signed_in? && @authorization_definition.applicant_eligibility == 'wallet_registry' && !wallet_registry_answer_change?
  end

  def redirect_to_wallet_registry_form
    flash.keep
    redirect_to new_authorization_request_form_path(form_uid: @authorization_definition.available_forms.first.id, profil: wallet_registry_answer)
  end

  def render_refusal
    raise unless current_organization&.closed?

    render 'closed_organization'
  end

  def find_authorization_definition
    @authorization_definition = AuthorizationDefinition.find(id_sanitized)
    raise StaticApplicationRecord::EntryNotFound unless @authorization_definition.feature_flag_enabled?
  rescue StaticApplicationRecord::EntryNotFound
    raise ActiveRecord::RecordNotFound, "AuthorizationDefinition with id '#{id_sanitized}' not found"
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

    render 'pages/connexion'
  end

  def new_as_guest_user
    @authorization_definition = AuthorizationDefinition.find(id_sanitized)
    save_redirect_path
    @display_provider_logo_in_header = true

    if @eligibility_rule && params[:eligibility_confirmed] != 'true'
      render_eligibility_check
    else
      render 'authorization_requests/unauthenticated_start'
    end
  end

  def render_eligibility_check
    @display_provider_logo_in_header = true

    render 'authorization_requests/eligibility_check'
  end

  def id_sanitized
    params.expect(:definition_id).underscore
  end

  def find_eligibility_rule
    @eligibility_rule = EligibilityRule.find_by(definition_id: id_sanitized)
  end
end
