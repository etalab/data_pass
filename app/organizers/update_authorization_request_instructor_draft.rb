class UpdateAuthorizationRequestInstructorDraft < ApplicationOrganizer
  before do
    context.authorization_request_params ||= ActionController::Parameters.new
    context.authorization_request = context.authorization_request_instructor_draft.request
    context.skip_validation = true

    context.fail! if context.authorization_request_params.empty?
  end

  organize AssignParamsToAuthorizationRequest

  after do
    context.authorization_request_instructor_draft.data = context.authorization_request.data
    context.authorization_request_instructor_draft.save || context.fail!
  end
end
