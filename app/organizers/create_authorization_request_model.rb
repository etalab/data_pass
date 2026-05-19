class CreateAuthorizationRequestModel < ApplicationOrganizer
  organize AssignCreateParamsForCreateAuthorizationRequest,
    AssignDefaultDataToAuthorizationRequest,
    AssignQueryParamsDataToAuthorizationRequest,
    AssignParamsToAuthorizationRequest,
    AssignFranceConnectDefaults,
    SaveAuthorizationRequest
end
