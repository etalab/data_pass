class UpdateAuthorizationRequestFromAPI < ApplicationOrganizer
  before do
    context.event_name = 'update_by_api'
    context.event_entity = :changelog
    context.save_context ||= :update
    context.skip_validation = true
  end

  organize EnsureAuthorizationRequestIsUpdatable,
    ValidateAPIDataKeys,
    AssignParamsToAuthorizationRequest,
    AssignFranceConnectDefaults,
    SaveAuthorizationRequest,
    CreateAuthorizationRequestChangelog,
    CreateAuthorizationRequestEventModel
end
