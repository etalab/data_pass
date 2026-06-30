class Instruction::AuthorizationRequestsController < Instruction::AbstractAuthorizationRequestsController
  def show
    authorize [:instruction, @authorization_request]

    @entity_eligibility_verdict = EntityEligibility::Engine.from_request(@authorization_request).verdict

    render 'show', layout: 'instruction/authorization_request'
  end

  private

  def extract_authorization_request
    @authorization_request = AuthorizationRequest.find(params.expect(:id)).decorate
  end
end
