class UpdateAuthorizationRequest < ApplicationOrganizer
  before do
    context.event_name = 'update'
  end

  organize AssignParamsToAuthorizationRequest,
    CreateAuthorizationRequestEventModel

  after do
    context.authorization_request.save ||
      context.fail!
  end
end
