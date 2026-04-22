class AfterCreateAuthorizationRequest < ApplicationOrganizer
  organize CreateAuthorizationRequestEventModel,
    DeliverAuthorizationRequestNotification
end
