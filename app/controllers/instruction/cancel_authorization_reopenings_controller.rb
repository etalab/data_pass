class Instruction::CancelAuthorizationReopeningsController < Instruction::AbstractAuthorizationRequestsController
  before_action :authorize_authorization_request_reopening_cancellation

  def new
    @authorization_request_reopening_cancellation = @authorization_request.reopening_cancellations.build
  end

  def create
    organizer = CancelAuthorizationReopening.call(authorization_request_reopening_cancellation_params:, authorization_request: @authorization_request, user: current_user)

    @authorization_request_reopening_cancellation = organizer.authorization_request_reopening_cancellation

    if organizer.success?
      success_message_for_authorization_request(@authorization_request, key: 'instruction.cancel_authorization_reopenings.create')

      redirect_to instruction_dashboard_show_path(id: 'demandes'),
        status: :see_other
    else
      render 'new'
    end
  end

  private

  def authorization_request_reopening_cancellation_params
    params.expect(
      authorization_request_reopening_cancellation: [:reason],
    )
  end

  def authorize_authorization_request_reopening_cancellation
    authorize [:instruction, @authorization_request], :cancel_reopening?
  end

  def model_to_track_for_impersonation
    @authorization_request
  end
end
