class Instruction::AuthorizationRequestEventsController < Instruction::AbstractAuthorizationRequestsController
  def index
    authorize [:instruction, @authorization_request], :show?

    @events = @authorization_request.events.includes(%i[user entity]).order(created_at: :desc)
  end

  private

  def layout_name
    'instruction/authorization_request'
  end
end
