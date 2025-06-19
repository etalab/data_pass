class Instruction::AbstractAuthorizationRequestsController < InstructionController
  helper AuthorizationRequestsHelpers
  include AuthorizationRequestsFlashes

  before_action :extract_authorization_request

  decorates_assigned :authorization_request

  protected

  def extract_authorization_request
    @authorization_request = AuthorizationRequest.find(params[:authorization_request_id])
  end
end
