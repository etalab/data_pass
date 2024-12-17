class ClaimInstructorDraftRequest < ApplicationOrganizer
  before do
    context.organization = context.instructor_draft_request&.organization
    context.user = context.instructor_draft_request&.applicant
    context.event_name = 'claim'
    context.event_entity = :instructor_draft_request
  end

  organize EnsureInstructorDraftNotClaimed,
    EnsureUserIsOrganizationMember,
    CreateAuthorizationRequestFromInstructorDraft,
    CreateAuthorizationRequestEventModel,
    CopyDocumentsFromInstructorDraft,
    MarkInstructorDraftAsClaimed
end
