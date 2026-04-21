class CreateAuthorizationRequest < ApplicationOrganizer
  before do
    context.authorization_request_params ||= ActionController::Parameters.new
    context.event_name = 'create'
  end

  organize CreateAuthorizationRequestModel,
    AfterCreateAuthorizationRequest
end
