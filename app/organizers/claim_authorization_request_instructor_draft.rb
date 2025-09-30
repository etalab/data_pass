class ClaimAuthorizationRequestInstructorDraft < ApplicationOrganizer
  before do
    context.organization = context.authorization_request_instructor_draft&.organization
    context.user = context.authorization_request_instructor_draft&.applicant
  end

  organize EnsureInstructorDraftNotClaimed,
    EnsureUserIsOrganizationMember,
    CreateAuthorizationRequestFromInstructorDraft,
    CopyDocumentsFromInstructorDraft,
    MarkInstructorDraftAsClaimed
end
