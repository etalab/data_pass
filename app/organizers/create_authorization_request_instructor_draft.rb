class CreateAuthorizationRequestInstructorDraft < ApplicationOrganizer
  before do
    context.authorization_request_params ||= ActionController::Parameters.new
    context.authorization_request_instructor_draft_params ||= {}
  end

  organize BuildAuthorizationRequestInstructorDraftModels,
    AssignParamsToAuthorizationRequest

  after do
    context.authorization_request_instructor_draft.data = context.authorization_request.data
    context.authorization_request_instructor_draft.save || context.fail!
  end
end
