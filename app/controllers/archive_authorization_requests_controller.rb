class ArchiveAuthorizationRequestsController < AuthenticatedUserController
  before_action :extract_authorization_request
  before_action :authorize_authorization_request_archive

  def new; end

  def create
    organizer = ArchiveAuthorizationRequest.call(authorization_request: @authorization_request, user: current_user)

    if organizer.success?
      success_message(title: t('.success', name: @authorization_request.name))

      redirect_to after_archive_path,
        status: :see_other
    else
      render 'new'
    end
  end

  private

  def extract_authorization_request
    @authorization_request = AuthorizationRequest.find(params.expect(:authorization_request_id)).decorate
  end

  def after_archive_path
    if @authorization_request.definition.feature?(:return_to_introduction_after_archive)
      authorization_request_form_introduction_path(form_uid: @authorization_request.form_uid)
    else
      dashboard_path
    end
  end

  def authorize_authorization_request_archive
    authorize @authorization_request, :archive?
  end

  def model_to_track_for_impersonation
    @authorization_request
  end
end
