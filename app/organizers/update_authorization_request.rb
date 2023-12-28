class UpdateAuthorizationRequest < ApplicationOrganizer
  organize AssignParamsToAuthorizationRequest

  after do
    context.authorization_request.save ||
      context.fail!
  end
end
