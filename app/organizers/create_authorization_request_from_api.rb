class CreateAuthorizationRequestFromAPI < ApplicationOrganizer
  before do
    context.authorization_request_params ||= ActionController::Parameters.new
    context.event_name = 'create_by_api'
    context.event_entity = :changelog
    context.identity_federator = 'unknown'
    context.skip_validation = true
  end

  organize ResolveAuthorizationRequestForm,
    ValidateAPIDataKeys,
    FindOrCreateApplicantFromAPI,
    FindOrCreateOrganizationForAPI,
    LinkApplicantToOrganization,
    AssignAPIAuthorizationRequestModel,
    AssignDefaultDataToAuthorizationRequest,
    AssignParamsToAuthorizationRequest,
    AssignFranceConnectDefaults,
    SaveAuthorizationRequest,
    CreateAuthorizationRequestChangelog,
    CreateAuthorizationRequestEventModel,
    EnqueueOrganizationINSEERefresh
end
