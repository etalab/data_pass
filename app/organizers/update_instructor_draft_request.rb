class UpdateInstructorDraftRequest < ApplicationOrganizer
  before do
    context.authorization_request_params ||= ActionController::Parameters.new
    context.authorization_request = context.instructor_draft_request.request
    context.skip_validation = true

    context.fail! if context.authorization_request_params.empty?
  end

  organize AssignParamsToAuthorizationRequest

  after do
    context.instructor_draft_request.data = context.authorization_request.data
    context.instructor_draft_request.save || context.fail!
  end
end
