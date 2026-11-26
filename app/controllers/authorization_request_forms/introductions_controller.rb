class AuthorizationRequestForms::IntroductionsController < AuthenticatedUserController
  helper AuthorizationRequestsHelpers
  helper DemandesHabilitations::CommonHelper
  include WalletRegistryEntry

  allow_unauthenticated_access

  rescue_from StaticApplicationRecord::EntryNotFound do
    redirect_to root_path, alert: t('authorization_request_forms.form_not_found')
  end

  before_action :extract_authorization_request_form
  before_action :ensure_feature_flag_enabled
  before_action :enter_wallet_registry, if: :wallet_registry_form?

  def show
    prefill.capture(request.query_parameters)

    authorize @authorization_request_form, :new?

    user_signed_in? ? render(layout: 'form_introduction') : come_back_here_after_sign_in
  rescue Pundit::NotAuthorizedError
    explain_unavailable_form
    redirect_to_definition_page
  end

  private

  def come_back_here_after_sign_in
    save_redirect_path
    redirect_to_definition_page(formulaire: @authorization_request_form.id)
  end

  def redirect_to_definition_page(formulaire: nil)
    redirect_to new_authorization_request_path(definition_id: @authorization_request_form.authorization_definition.id, formulaire:)
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
