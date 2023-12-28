class CreateAuthorizationRequest < ApplicationOrganizer
  before do
    context.authorization_request_params ||= ActionController::Parameters.new
  end

  organize CreateAuthorizationRequestModel,
    AssignDefaultDataToAuthorizationRequest,
    AssignParamsToAuthorizationRequest

  after do
    context.authorization_request.save ||
      context.fail!
  end
end
