def create_or_find_authorization(request, current_user, state)
  authorization = request.authorizations.first ||
                  FactoryBot.create(:authorization,
                    request: request,
                    applicant: current_user,
                    data: request.data.dup,
                    form_uid: request.form_uid)

  case state
  when 'active'
    authorization.update!(state: 'active', revoked: false)
  when 'revoked'
    authorization.update!(state: 'revoked', revoked: true)
  end

  authorization.slug = nil
  authorization.save!

  authorization
end

Quand(/j'ai (\d+) habilitation "([^"]+)" (.+?)(?: de l'étape "([^"]+)")?(?: via le formulaire "([^"]+)")?$/) do |count, type, state, stage, form|
  attributes = { applicant: current_user }

  @authorization_requests = create_authorization_requests_with_status(
    type,
    state == 'active' ? 'validée' : 'révoquée',
    count.to_i,
    stage,
    form,
    attributes
  )

  @authorization_request = @authorization_requests.first

  @authorizations = @authorization_requests.map do |request|
    create_or_find_authorization(request, current_user, state)
  end

  @authorization = @authorizations.first
end

Et('je visite la page de mon habilitation') do
  visit authorization_path(@authorization)
end

Alors('il y a un formulaire en mode résumé non modifiable') do
  expect(page).to have_current_path(%r{/habilitations/#{@authorization.slug}})

  # Verify the form is not editable by checking if inputs are disabled or read-only
  expect(page).to have_css('input[disabled]') if page.has_css?('input')
  expect(page).to have_css('select[disabled]') if page.has_css?('select')
  expect(page).to have_css('textarea[disabled]') if page.has_css?('textarea')
end
