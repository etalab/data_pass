class NextAuthorizationRequestStageController < AuthenticatedUserController
  before_action :extract_authorization_request
  before_action :extract_authorization_request_next_form

  def new
    authorize @authorization_request, :start_next_stage?

    render 'authorization_request_forms/new', layout: 'form_introduction'
  end

  def create
    authorize @authorization_request, :start_next_stage?

    StartNextAuthorizationRequestStage.call(authorization_request: @authorization_request, user: current_user)

    redirect_to authorization_request_path(@authorization_request)
  end

  private

  def extract_authorization_request
    @authorization_request = AuthorizationRequest.find(params[:authorization_request_id])
  end

  def extract_authorization_request_next_form
    @authorization_request_form = @authorization_request.definition.next_stage_form
  end
end
