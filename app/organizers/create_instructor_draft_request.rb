class CreateInstructorDraftRequest < ApplicationOrganizer
  before do
    context.authorization_request_params ||= ActionController::Parameters.new
    context.instructor_draft_request_params ||= {}
  end

  organize BuildInstructorDraftRequestModels,
    AssignParamsToAuthorizationRequest,
    SaveInstructorDraftRequest,
    AssignDocumentsToInstructorDraftRequest
end
