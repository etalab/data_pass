class UpdateAuthorizationRequestFromAPI < ApplicationOrganizer
  before do
    context.event_name = 'update_by_api'
    context.event_entity = :changelog
    context.save_context ||= :update
  end

  organize EnsureAuthorizationRequestIsUpdatable,
    ValidateAPIDataKeys,
    UpdateAuthorizationRequestModel,
    CreateAuthorizationRequestChangelog,
    AfterUpdateAuthorizationRequest
end
