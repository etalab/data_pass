class InviteApplicantToClaimAuthorizationRequestInstructorDraft < ApplicationOrganizer
  organize FindOrCreateUserByEmail,
    CreateOrganizationFromSiret,
    AddUserToOrganization,
    UpdateAuthorizationRequestInstructorDraftWithUserAndOrganization,
    RegenerateAuthorizationRequestInstructorDraftPublicId,
    SendInvitationEmailAuthorizationRequestInstructorDraft
end
