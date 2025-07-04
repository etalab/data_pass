class Instruction::AuthorizationsController < Instruction::AbstractAuthorizationRequestsController
  decorates_assigned :authorizations

  def index
    authorize [:instruction, @authorization_request], :show?

    @authorizations = AuthorizationRequest
      .find(params[:authorization_request_id])
      .authorizations
      .includes(:approving_instructor)
      .order(created_at: :desc)
  end

  private

  def layout_name
    'instruction/authorization_request'
  end
end
