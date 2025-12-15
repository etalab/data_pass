class InviteApplicantToClaimInstructorDraftRequest < ApplicationOrganizer
  before do
    context.organization_params = {
      legal_entity_id: context.organization_siret,
      legal_entity_registry: 'insee_sirene',
    }

    context.identity_federator = 'unknown'
    context.instructor_draft_request.comment = context.comment
    context.user_email = context.applicant_email
  end

  organize FindOrCreateUserByEmail,
    FindOrCreateOrganization,
    AddUserToOrganization,
    UpdateInstructorDraftRequestWithUserAndOrganization,
    RegenerateInstructorDraftRequestPublicId,
    SendInvitationEmailInstructorDraftRequest
end
