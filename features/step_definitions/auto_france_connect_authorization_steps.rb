Sachantque('il existe un webhook activé pour FranceConnect avec l\'URL {string}') do |url|
  @webhook = FactoryBot.create(
    :webhook,
    :active,
    authorization_definition_id: 'france_connect',
    url: url
  )
end

Sachantque('il y a une demande API Particulier avec champs FranceConnect intégrés à modérer') do
  @authorization_request = FactoryBot.create(
    :authorization_request,
    :api_particulier,
    :submitted,
    :with_france_connect_embedded_fields
  )
end

Sachantque('il y a une demande API Particulier sans champs FranceConnect à modérer') do
  @authorization_request = FactoryBot.create(
    :authorization_request,
    :api_particulier,
    :submitted
  )
end

Sachantque('il y a une demande API Particulier avec champs FranceConnect intégrés validée') do
  @authorization_request = FactoryBot.create(
    :authorization_request,
    :api_particulier,
    :submitted,
    :with_france_connect_embedded_fields
  )

  instructor = FactoryBot.create(:user, :instructor, authorization_request_types: %w[api_particulier])
  ApproveAuthorizationRequest.call(authorization_request: @authorization_request, user: instructor)
end

Sachantque("j'ai une demande API Particulier avec champs FranceConnect intégrés validée") do
  @authorization_request = FactoryBot.create(
    :authorization_request,
    :api_particulier,
    :submitted,
    :with_france_connect_embedded_fields,
    applicant: current_user,
    organization: current_user.current_organization
  )

  instructor = FactoryBot.create(:user, :instructor, authorization_request_types: %w[api_particulier])
  ApproveAuthorizationRequest.call(authorization_request: @authorization_request, user: instructor)

  @authorization = @authorization_request.authorizations.find_by(authorization_request_class: 'AuthorizationRequest::APIParticulier')
end

Quand('je me rends sur la demande instruction d\'une API Particulier avec champs FranceConnect intégrés validée') do
  @authorization_request = FactoryBot.create(
    :authorization_request,
    :api_particulier,
    :submitted,
    :with_france_connect_embedded_fields
  )

  instructor = FactoryBot.create(:user, :instructor, authorization_request_types: %w[api_particulier])
  ApproveAuthorizationRequest.call(authorization_request: @authorization_request, user: instructor)

  visit instruction_authorization_request_path(@authorization_request)
end

Alors('il y a {int} habilitation(s) pour cette demande') do |count|
  expect(@authorization_request.reload.authorizations.count).to eq(count)
end

Alors('un webhook avec l\'évènement {string} est envoyé pour FranceConnect') do |event_name|
  webhook_job = ActiveJob::Base.queue_adapter.enqueued_jobs.find do |job|
    next unless job['job_class'] == 'DeliverAuthorizationRequestWebhookJob'

    webhook_id = job['arguments'][0]
    webhook = Webhook.find_by(id: webhook_id)
    next unless webhook

    payload = job['arguments'][3]
    event = payload[:event] || payload['event']

    webhook.authorization_definition_id == 'france_connect' && event == event_name
  end

  expect(webhook_job).not_to be_nil
end

Alors("l'habilitation FranceConnect liée n'est pas réouvrable") do
  fc_authorization = @authorization_request.authorizations.find_by(
    authorization_request_class: 'AuthorizationRequest::FranceConnect'
  )

  expect(fc_authorization).not_to be_nil
  expect(fc_authorization.reopenable?).to be false
end
