Sachantque('il existe un webhook pour {string} avec l\'URL {string}') do |authorization_definition_id, url|
  @webhook = FactoryBot.create(
    :webhook,
    :validated,
    authorization_definition_id: authorization_definition_id.parameterize.underscore,
    url: url,
    events: %w[approve submit],
    enabled: false
  )
end

Sachantque('il existe un webhook activé pour {string} avec l\'URL {string}') do |authorization_definition_id, url|
  @webhook = FactoryBot.create(
    :webhook,
    :active,
    authorization_definition_id: authorization_definition_id.parameterize.underscore,
    url: url
  )
end

Sachantque('ce webhook a reçu {int} appels') do |count|
  authorization_request = FactoryBot.create(:authorization_request, :api_entreprise)
  count.times do
    FactoryBot.create(
      :webhook_attempt,
      webhook: @webhook,
      authorization_request: authorization_request,
      event_name: 'approve',
      status_code: 200
    )
  end
end

Sachantque('ce webhook a reçu un appel avec le statut {string}') do |status_code|
  authorization_request = FactoryBot.create(:authorization_request, :api_entreprise)
  @webhook_attempt = FactoryBot.create(
    :webhook_attempt,
    webhook: @webhook,
    authorization_request: authorization_request,
    event_name: 'approve',
    status_code: status_code.to_i
  )
end

Quand('je me rends sur le chemin des appels de ce webhook') do
  visit developers_webhook_webhook_attempts_path(@webhook)
end

Quand('je clique sur le premier appel') do
  within('#calls-table tbody') do
    first('.fr-btn', text: I18n.t('developers.webhook_attempts.index.view_details')).click
  end
end

Alors('je vois {int} appels dans la liste') do |count|
  within('#calls-table tbody') do
    expect(page).to have_css('tr', count: count)
  end
end

Alors('je vois le badge {string}') do |badge_text|
  expect(page).to have_css('.fr-badge', text: badge_text)
end

Quand('je clique sur {string} pour le premier appel') do |link_text|
  within('#calls-table tbody') do
    first('.fr-btn', text: link_text).click
  end
end

Alors('je vois un secret de {int} caractères') do |length|
  secret_field = find_by_id('webhook-secret-value')
  @displayed_secret = secret_field.value
  expect(@displayed_secret).to be_present
  expect(@displayed_secret.length).to eq(length)
end

Alors('la page ne contient pas le secret affiché précédemment') do
  expect(page).to have_no_content(@displayed_secret)
end
