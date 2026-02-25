class ReviewAuthorizationRequest < ApplicationOrganizer
  before do
    context.authorization_request_params ||= ActionController::Parameters.new
    context.save_context = :review
    context.skip_validation = true
    context.fail! unless context.authorization_request.filling?
  end

  organize AssignParamsToAuthorizationRequest,
    AssignFranceConnectDefaultsOnReopening

  after do
    context.authorization_request.save(context: context.save_context) ||
      context.fail!
  end
end
