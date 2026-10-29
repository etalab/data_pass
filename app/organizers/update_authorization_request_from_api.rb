class UpdateAuthorizationRequestFromAPI < ApplicationOrganizer
  before do
    context.event_name = 'update_by_api'
    context.event_entity = :changelog
    context.save_context ||= :update
    context.skip_empty_changelog = true
  end

  organize EnsureAuthorizationRequestIsUpdatable,
    ValidateAPIDataKeys,
    ValidateAPIMetadata,
    UpdateAuthorizationRequestModel,
    AssignAPIMetadataToAuthorizationRequest,
    CreateAuthorizationRequestChangelog,
    AfterUpdateAuthorizationRequestWithChanges
end
