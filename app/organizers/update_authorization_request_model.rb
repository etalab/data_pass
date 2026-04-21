class UpdateAuthorizationRequestModel < ApplicationOrganizer
  organize AssignParamsToAuthorizationRequest,
    AssignFranceConnectDefaults,
    SaveAuthorizationRequest
end
