class Admin::TransferAuthorizationRequest < ApplicationOrganizer
  organize FindAuthorizationRequest,
    FindOrganization,
    FindApplicant,
    CheckApplicantBelongsToOrganization,
    TransferAuthorizationRequestToNewOrganization
end
