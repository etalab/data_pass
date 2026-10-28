Quand('la demande est soumise par API via l’application {string}') do |application_name|
  authorization_request = AuthorizationRequest.last
  FactoryBot.create(
    :authorization_request_event, :create_by_api,
    authorization_request:,
    entity: CreateAuthorizationRequestChangelog.call!(authorization_request:).changelog
  )

  SubmitAuthorizationRequestFromAPI.call!(
    authorization_request:,
    consentement: ActionController::Parameters.new(authorization_request.required_consents.index_with(true)),
    oauth_application: FactoryBot.create(:oauth_application, name: application_name)
  )
end
