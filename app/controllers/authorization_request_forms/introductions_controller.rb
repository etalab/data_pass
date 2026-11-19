class AuthorizationRequestForms::IntroductionsController < AuthenticatedUserController
  helper AuthorizationRequestsHelpers
  helper DemandesHabilitations::CommonHelper

  allow_unauthenticated_access

  rescue_from StaticApplicationRecord::EntryNotFound do
    redirect_to root_path, alert: t('authorization_request_forms.form_not_found')
  end

  before_action :extract_authorization_request_form
  before_action :ensure_feature_flag_enabled

  def show
    prefill.capture(request.query_parameters)

    authorize @authorization_request_form, :new?

    user_signed_in? ? render_introduction : render_unauthenticated_start
  rescue Pundit::NotAuthorizedError
    explain_unavailable_form
    redirect_to new_authorization_request_path(definition_id: @authorization_request_form.authorization_definition.id)
  end

  private

  def render_introduction
    render layout: 'form_introduction'
  end

  def render_unauthenticated_start
    @authorization_definition = @authorization_request_form.authorization_definition

    save_redirect_path
    render 'authorization_requests/unauthenticated_start', layout: 'authorization_request'
  end

  def explain_unavailable_form
    return unless @authorization_request_form.uid == 'api-entreprise-editeur'

    info_message(
      title: t('authorization_request_forms.new.editor_form_unavailable.title'),
      description: t('authorization_request_forms.new.editor_form_unavailable.description'),
      link: { label: t('authorization_request_forms.new.editor_form_unavailable.link'), url: editor_questionnaire_url },
    )
  end

  def editor_questionnaire_url
    EligibilityRule.find_by(definition_id: 'api_entreprise').options.find { |option| option.type == 'entreprise_ou_association' }.cta['url']
  end

  def prefill
    AuthorizationRequestPrefill.new(session, @authorization_request_form)
  end

  def extract_authorization_request_form
    @authorization_request_form = AuthorizationRequestForm.find(params.expect(:form_uid)).decorate
  end

  def ensure_feature_flag_enabled
    raise StaticApplicationRecord::EntryNotFound unless @authorization_request_form.authorization_definition.feature_flag_enabled?
  end
end
