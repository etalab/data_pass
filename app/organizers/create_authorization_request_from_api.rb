class CreateAuthorizationRequestFromAPI < ApplicationOrganizer
  before do
    context.authorization_request_params ||= ActionController::Parameters.new
    context.event_name = 'create_by_api'
    context.event_entity = :changelog
  end

  organize ResolveAuthorizationRequestForm,
    ValidateAPIDataKeys,
    ProvisionApplicantFromAPI,
    EnsureAuthorizationRequestCanBeCreated,
    CreateAuthorizationRequestModel,
    CreateAuthorizationRequestChangelog,
    AfterCreateAuthorizationRequest,
    EnqueueOrganizationINSEERefresh
end
