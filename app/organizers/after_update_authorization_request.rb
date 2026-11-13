class AfterUpdateAuthorizationRequest < ApplicationOrganizer
  organize CreateAuthorizationRequestEventModel,
    DeliverAuthorizationRequestNotification
end
