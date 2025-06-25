class Instruction::AuthorizationRequestsController < Instruction::AbstractAuthorizationRequestsController
  decorates_assigned :authorization_request

  def show
    authorize [:instruction, @authorization_request]

    render 'show', layout: 'instruction/authorization_request'
  end

  private

  def extract_authorization_request
    @authorization_request = AuthorizationRequest.find(params[:id])
  end
end
