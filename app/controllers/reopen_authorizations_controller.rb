class ReopenAuthorizationsController < AuthenticatedUserController
  before_action :extract_authorization, :extract_authorization_request_class
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
      authorization_request_class: @authorization_request_class
    )
  end

  def summary_path
    summary_authorization_request_form_path(
      form_uid: @authorization.authorization_request.form.uid,
      id: @authorization.authorization_request.id,
    )
  end

  def extract_authorization
    authorization_request = AuthorizationRequest.find(params[:authorization_request_id])
    @authorization = authorization_request.authorizations.friendly.find(params[:authorization_id])
  end

  def extract_authorization_request_class
    return if params[:authorization_request_class].blank?

    request_classes_hash = AuthorizationDefinition.all_request_classes.to_h { |klass| [klass.to_s, klass] }
    actual_authorization_request_class = request_classes_hash[params[:authorization_request_class]]

    raise ActionController::UnpermittedParameters unless actual_authorization_request_class.present?

    @authorization_request_class = actual_authorization_request_class
  end

  def authorize_authorization_reopening
    authorize @authorization, :reopen?
  end
end
