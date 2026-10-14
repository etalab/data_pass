class CreateAuthorizationRequestFromAPI < ApplicationOrganizer
  before do
    context.authorization_request_params ||= ActionController::Parameters.new
    context.event_name = 'create_by_api'
    context.event_entity = :changelog
    context.skip_validation = true
  end

  organize ResolveAuthorizationRequestForm,
    ValidateAPIDataKeys,
    ProvisionApplicantFromAPI,
    CreateAuthorizationRequestModel,
    CreateAuthorizationRequestChangelog,
    AfterCreateAuthorizationRequest,
    EnqueueOrganizationINSEERefresh
end
