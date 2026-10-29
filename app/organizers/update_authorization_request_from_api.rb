class UpdateAuthorizationRequestFromAPI < ApplicationOrganizer
  before do
    context.event_name = 'update_by_api'
    context.event_entity = :changelog
    context.event_source = 'api'
    context.save_context ||= :update
  end

  around do |organizer|
    ActiveRecord::Base.transaction { organizer.call }
  end

  organize EnsureAuthorizationRequestIsUpdatable,
    ValidateAPIDataKeys,
    ValidateAPIMetadata,
    UpdateAuthorizationRequestModel,
    AssignAPIMetadataToAuthorizationRequest,
    CreateAuthorizationRequestChangelog,
    AfterUpdateAuthorizationRequest
end
