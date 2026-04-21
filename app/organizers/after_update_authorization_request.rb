class AfterUpdateAuthorizationRequest < ApplicationOrganizer
  organize VerifyContactsEmailsAsynchronously,
    CreateAuthorizationRequestEventModel,
    DeliverAuthorizationRequestNotification
end
