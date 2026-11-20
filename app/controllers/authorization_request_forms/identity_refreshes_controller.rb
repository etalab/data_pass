class AuthorizationRequestForms::IdentityRefreshesController < AuthorizationRequestFormsController
  skip_before_action :guard_wallet_registry_start
  before_action :extract_authorization_request, only: :create

  rate_limit to: 5, within: 1.minute, only: :create, with: -> { redirect_back_or_to root_path }

  def create
    authorize @authorization_request, :refresh_identity?

    identity_source_before = @authorization_request.try(:identity_source)
    @identity_refreshed = refresh_identity.success?

    if @authorization_request.try(:identity_source) == identity_source_before
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_with_refresh_result }
      end
    else
      redirect_with_refresh_result(announce_failure: false)
    end
  end

  private

  def refresh_identity
    RefreshAuthorizationRequestIdentity.call(authorization_request: @authorization_request.object)
  end

  def redirect_with_refresh_result(announce_failure: true)
    if @identity_refreshed
      success_message(title: t('authorization_request_forms.identity_refreshes.create.success.title'))
    elsif announce_failure
      warning_message(title: t('authorization_request_forms.identity_refreshes.create.unavailable.title'), description: t('authorization_request_forms.identity_refreshes.create.unavailable.description', support_email: @authorization_request.definition.support_email))
    end

    redirect_back_or_to summary_authorization_request_form_path(form_uid: @authorization_request.form_uid, id: @authorization_request.id), status: :see_other
  end

  def extract_authorization_request
    @authorization_request = authorization_request_class.find(params.expect(:authorization_request_id)).decorate
  end
end
