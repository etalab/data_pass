class Instruction::FranceConnectedAuthorizationsController < Instruction::AbstractAuthorizationRequestsController
  def index
    authorize [:instruction, @authorization_request], :show?

    @france_connected_authorizations = @authorization_request.france_connected_authorizations.decorate
  end

  private

  def layout_name
    'instruction/authorization_request'
  end
end
