class ExternalReopenAuthorizationRequestsController < AuthenticatedUserController
  before_action :extract_authorization
  before_action :authorize_authorization_reopening

  def create
    success_message(title: t('reopen_authorizations.create.success.title', name: @authorization.authorization_request.name)) if reopen_authorization.success?

    redirect_to summary_path
  end

  private

  def reopen_authorization
    ReopenAuthorization.call(
      authorization: @authorization,
      user: current_user,
    )
  end

  def summary_path
    summary_authorization_request_form_path(
      form_uid: @authorization_request.form.uid,
      id: @authorization_request.id,
    )
  end

  def extract_authorization
    @authorization_request = AuthorizationRequest.find(params[:id])
    @authorization = @authorization_request.latest_authorization
  end

  def authorize_authorization_reopening
    authorize @authorization, :reopen?
  rescue Pundit::NotAuthorizedError, Pundit::NotDefinedError
    redirect_to summary_path
  end

  def model_to_track_for_impersonation
    @authorization_request
  end
end
