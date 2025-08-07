class InviteApplicantToClaimAuthorizationRequestInstructorDraft < ApplicationOrganizer
  before do
    context.organization_params = {
      legal_entity_id: context.organization_siret,
      legal_entity_registry: 'insee_sirene',
    }

    context.identity_federator = 'unknown'
  end

  organize FindOrCreateUserByEmail,
    FindOrCreateOrganization,
    AddUserToOrganization,
    UpdateAuthorizationRequestInstructorDraftWithUserAndOrganization,
    RegenerateAuthorizationRequestInstructorDraftPublicId,
    SendInvitationEmailAuthorizationRequestInstructorDraft
end
