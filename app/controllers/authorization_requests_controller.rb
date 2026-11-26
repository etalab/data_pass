class AuthorizationRequestsController < AuthenticatedUserController
  helper AuthorizationRequestsHelpers
  include SubdomainsHelper

  allow_unauthenticated_access only: %i[new show]

  before_action :find_enabled_authorization_definition, only: %i[new]
  before_action :set_facade, only: %i[new]
  before_action :find_eligibility_rule, only: %i[new]

  decorates_assigned :eligibility_rule

  def new
    return render_eligibility_check if eligibility_check_pending?
    return render_sign_in unless user_signed_in?

    authorize @authorization_definition, :new?

    render_form_choice
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

  def render_refusal
    return render custom_refusal_template if template_exists?(custom_refusal_template)
    raise unless current_organization&.closed?

    render 'closed_organization'
  end

  def custom_refusal_template
    "authorization_requests/refusals/#{@authorization_definition.id}"
  end

  def find_enabled_authorization_definition
    @authorization_definition = AuthorizationDefinition.find(id_sanitized)

    raise ActiveRecord::RecordNotFound unless @authorization_definition.feature_flag_enabled?
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

  def eligibility_check_pending?
    return false if @eligibility_rule.nil?

    changing_answer? || (!user_signed_in? && params[:eligibility_confirmed] != 'true')
  end

  def changing_answer?
    params[:changer_de_reponse] == 'true'
  end

  def render_eligibility_check
    remember_page_for_sign_in unless user_signed_in?
    @display_provider_logo_in_header = true

    render 'authorization_requests/eligibility_check'
  end

  def render_sign_in
    remember_page_for_sign_in
    @display_provider_logo_in_header = true

    render 'authorization_requests/unauthenticated_start'
  end

  def remember_page_for_sign_in
    save_redirect_path unless requested_form
  end

  def render_form_choice
    if requested_form
      redirect_to_introduction(requested_form)
    elsif template_exists?(custom_form_choice_template)
      render custom_form_choice_template
    elsif @authorization_definition.public_available_forms.many?
      render 'authorization_requests/new/default', layout: 'form_introduction'
    else
      redirect_to_introduction(@authorization_definition.public_available_forms.first)
    end
  end

  def requested_form
    @authorization_definition.available_forms.find { |form| form.id == params[:formulaire] }
  end

  def custom_form_choice_template
    "authorization_requests/new/#{@authorization_definition.id}"
  end

  def redirect_to_introduction(form)
    flash.keep
    redirect_to authorization_request_form_introduction_path(form_uid: form.id)
  end

  def id_sanitized
    params.expect(:definition_id).underscore
  end

  def find_eligibility_rule
    @eligibility_rule = EligibilityRule.find_by(definition_id: id_sanitized)
  end
end
