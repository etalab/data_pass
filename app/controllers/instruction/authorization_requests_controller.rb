class Instruction::AuthorizationRequestsController < InstructionController
  def index
    @authorization_requests = policy_scope(AuthorizationRequest, policy_scope_class: Instruction::AuthorizationRequestPolicy::Scope).all
  end
end
