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
  when 'obsolete'
    authorization.update!(state: 'obsolete', revoked: false)
  end

  authorization.slug = nil
  authorization.save!

  authorization
end

Quand(/j'ai (\d+) habilitation "([^"]+)" (.+?)(?: (?:de|à) l'étape "([^"]+)")?(?: via le formulaire "([^"]+)")?$/) do |count, type, state, stage, form|
  attributes = { applicant: current_user }

  @authorization_requests = create_authorization_requests_with_status(
    type,
    state == 'révoquée' ? 'révoquée' : 'validée',
    count.to_i,
    stage,
    form,
    attributes
  )

  @authorization_request = @authorization_requests.first

  @authorizations = @authorization_requests.map do |request|
    create_or_find_authorization(request, current_user, extract_state_from_french_status(state))
  end

  @authorization = @authorizations.first
end

Et('je visite la page de mon habilitation') do
  visit authorization_path(@authorization)
end

Quand("j'ai une habilitation {string} liée à une demande d'habilitation ayant une habilitation obsolete ayant des données différentes") do |type|
  attributes = { applicant: current_user }

  @authorization_requests = create_authorization_requests_with_status(
    type,
    'validée',
    1,
    nil,
    nil,
    attributes
  )

  authorization_request = @authorization_requests.first
  obsolete_authorization = authorization_request.authorizations.first

  newest_authorization = obsolete_authorization.dup
  newest_authorization.data['scopes'] = ['new_scope']
  newest_authorization.save!

  authorization_request.data['scopes'] = ['new_scope']
  authorization_request.save!

  obsolete_authorization.data['scopes'] = ['old_scope']
  obsolete_authorization.state = 'obsolete'
  obsolete_authorization.save!

  @authorization = obsolete_authorization
end

Alors('il y a un formulaire en mode résumé non modifiable') do
  expect(page).to have_current_path(%r{/habilitations/#{@authorization.slug}})

  # Verify the form is not editable by checking if inputs are disabled or read-only
  expect(page).to have_css('input[disabled]') if page.has_css?('input')
  expect(page).to have_css('select[disabled]') if page.has_css?('select')
  expect(page).to have_css('textarea[disabled]') if page.has_css?('textarea')
end
