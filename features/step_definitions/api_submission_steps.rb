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

Quand('la demande est soumise par API via l’application {string} sans notifications') do |application_name|
  authorization_request = AuthorizationRequest.last
  provider_slug = authorization_request.definition.provider_slug
  data_provider = DataProvider.find_by(slug: provider_slug) || FactoryBot.create(:data_provider, slug: provider_slug)
  data_provider.update!(
    api_contract_options: { 'optional_notifications' => %w[applicant_submit_receipt instructors_new_request] }
  )

  SubmitAuthorizationRequestFromAPI.call!(
    authorization_request:,
    consentement: ActionController::Parameters.new(authorization_request.required_consents.index_with(true)),
    oauth_application: FactoryBot.create(:oauth_application, name: application_name),
    notifications: false
  )
end
