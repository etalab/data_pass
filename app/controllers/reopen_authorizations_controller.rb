class ReopenAuthorizationsController < AuthenticatedUserController
  before_action :extract_authorization
  before_action :authorize_authorization_reopening

  def new; end

  def create
    if reopen_authorization.success?
      success_message(title: t('.success.title', name: @authorization.authorization_request.name))

      redirect_to summary_path
    else
      error_message(title: t('.error.title'))

      redirect_to dashboard_path
    end
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
      form_uid: @authorization.authorization_request.form.uid,
      id: @authorization.authorization_request.id,
    )
  end

  def extract_authorization
    @authorization = Authorization.friendly.find(params[:authorization_id])
  end

  def authorize_authorization_reopening
    authorize @authorization, :reopen?
  end
end
