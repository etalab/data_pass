class Instruction::ApproveAuthorizationRequestsController < Instruction::AbstractAuthorizationRequestsController
  include Instruction::MessageTemplatesLoader

  before_action :authorize_authorization_request_approval

  def new
    @authorization = Authorization.new
  end

  def create
    organizer = ApproveAuthorizationRequest.call(
      authorization_request: @authorization_request,
      user: current_user,
      authorization_message: authorization_params[:message]
    )

    if organizer.success?
      success_message_for_authorization_request(@authorization_request, key: 'instruction.approve_authorization_requests.create')

      redirect_to instruction_dashboard_show_path(id: 'demandes'),
        status: :see_other
    else
      render 'new', status: :unprocessable_content
    end
  end

  private

  def authorization_params
    params.fetch(:authorization, {}).permit(:message)
  end

  def authorize_authorization_request_approval
    authorize [:instruction, @authorization_request], :approve?
  end

  def model_to_track_for_impersonation
    @authorization_request
  end

  def message_template_type
    :approval
  end
end
