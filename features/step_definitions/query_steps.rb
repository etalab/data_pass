Sachantque('le temps moyen de traitement est de {int} jours pour API Entreprise') do |duration|
  request = FactoryBot.create(:authorization_request, :api_entreprise)

  changelog = FactoryBot.create(:authorization_request_changelog, authorization_request: request)

  submit_date = Time.current - duration.days
  FactoryBot.create(
    :authorization_request_event,
    name: 'submit',
    entity: changelog,
    entity_type: 'AuthorizationRequestChangelog',
    created_at: submit_date
  )

  authorization = FactoryBot.create(:authorization, request: request)

  FactoryBot.create(
    :authorization_request_event,
    name: 'approve',
    entity: authorization,
    entity_type: 'Authorization',
    created_at: Time.current
  )
end
