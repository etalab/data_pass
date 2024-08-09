class TransferAuthorizationRequestToNewApplicant < ApplicationOrganizer
  before do
    context.event_entity = :authorization_request_transfer
    context.event_name = 'transfer'
    context.old_applicant = context.authorization_request.applicant
    context.old_entity = context.old_applicant
    context.new_entity = context.new_applicant
  end

  organize UpdateApplicantOnAuthorizationRequest,
    CreateAuthorizationRequestTransferModel,
    CreateAuthorizationRequestEventModel,
    DeliverAuthorizationRequestNotification
end
