class TransferAuthorizationRequestToNewOrganization < ApplicationOrganizer
  before do
    context.event_entity = :authorization_request_transfer
    context.event_name = 'transfer'
    context.old_organization = context.authorization_request.organization
    context.old_entity = context.old_organization
    context.new_entity = context.new_organization
  end

  organize UpdateOrganizationOnAuthorizationRequest,
    CreateAuthorizationRequestTransferModel,
    CreateAuthorizationRequestEventModel,
    DeliverAuthorizationRequestNotification
end
