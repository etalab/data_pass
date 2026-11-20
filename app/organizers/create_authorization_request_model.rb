class CreateAuthorizationRequestModel < ApplicationOrganizer
  organize AssignCreateParamsForCreateAuthorizationRequest,
    AssignDefaultDataToAuthorizationRequest,
    AssignQueryParamsDataToAuthorizationRequest,
    AssignIdentityToAuthorizationRequest,
    AssignParamsToAuthorizationRequest,
    AssignFranceConnectDefaults,
    SaveAuthorizationRequest
end
