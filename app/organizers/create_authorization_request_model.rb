class CreateAuthorizationRequestModel < ApplicationOrganizer
  organize AssignCreateParamsForCreateAuthorizationRequest,
    AssignDefaultDataToAuthorizationRequest,
    AssignParamsToAuthorizationRequest,
    AssignFranceConnectDefaults,
    SaveAuthorizationRequest
end
