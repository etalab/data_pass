class CreateAuthorizationRequestFromAPI < ApplicationOrganizer
  before do
    context.authorization_request_params ||= ActionController::Parameters.new
    context.event_name = 'create_by_api'
    context.event_entity = :changelog
    context.event_source = 'api'
    context.update_organization_insee_payload_now = true
    context.tolerate_insee_entity_not_found = true
  end

  organize ResolveAuthorizationRequestForm,
    ValidateAPIDataKeys,
    ProvisionApplicantFromAPI,
    EnsureAuthorizationRequestCanBeCreated,
    CreateAuthorizationRequestModel,
    CreateAuthorizationRequestChangelog,
    UpdateOrganizationINSEEPayload,
    AfterCreateAuthorizationRequest
end
