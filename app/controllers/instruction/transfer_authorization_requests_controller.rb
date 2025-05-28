class Instruction::TransferAuthorizationRequestsController < Instruction::AbstractAuthorizationRequestsController
  before_action :authorize_authorization_request_transfer

  def new
    @authorization_request_transfer = AuthorizationRequestTransfer.new
  end

  def create
    organizer = TransferAuthorizationRequestToNewApplicant.call(transfer_authorization_request_params)

    if organizer.success?
      success_message_for_authorization_request(@authorization_request, key: 'instruction.transfer_authorization_requests.create')

      redirect_to instruction_authorization_requests_path,
        status: :see_other
    else
      @authorization_request_transfer = AuthorizationRequestTransfer.new

      affect_local_error(organizer)

      render :new, status: :unprocessable_entity
    end
  end

  private

  def transfer_authorization_request_params
    {
      new_applicant_email: params.dig(:authorization_request_transfer, :to),
      authorization_request: @authorization_request,
      user: current_user,
    }
  end

  def authorize_authorization_request_transfer
    authorize @authorization_request, :transfer?, policy_class: Instruction::AuthorizationRequestPolicy
  end

  def affect_local_error(organizer)
    @error = t(
      ".error.#{organizer.error}",
      organization_name: @authorization_request.organization.name,
      organization_siret: @authorization_request.organization.siret,
    )
  end
end
