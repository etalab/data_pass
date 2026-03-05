class Instruction::CancelNextAuthorizationRequestStagesController < Instruction::AbstractAuthorizationRequestsController
  before_action :authorize_cancel_next_stage

  def new; end

  def create
    CancelNextAuthorizationRequestStage.call(authorization_request: @authorization_request, user: current_user)

    success_message_for_authorization_request(@authorization_request, key: 'instruction.cancel_next_authorization_request_stages.create')

    redirect_to instruction_dashboard_show_path(id: 'demandes'),
      status: :see_other
  end

  private

  def authorize_cancel_next_stage
    authorize [:instruction, @authorization_request], :cancel_next_stage?
  end

  def model_to_track_for_impersonation
    @authorization_request
  end
end
