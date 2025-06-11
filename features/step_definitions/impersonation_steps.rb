Sachantque('il existe un utilisateur {string}') do |email|
  @user = FactoryBot.create(:user, email: email)
end

Sachantque('j\'impersonne l\'utilisateur {string}') do |email|
  visit new_admin_impersonate_path
  fill_in 'Email de l\'utilisateur', with: email
  fill_in 'Raison de l\'impersonation', with: 'Test impersonation'
  click_button 'Commencer l\'impersonation'
end

Sachantqu('il existe une habilitation {string} en {string}') do |definition, _target_api|
  # Authorization definitions are loaded from config files, no need to create them
  definition_exists = AuthorizationDefinition.find(definition)
  raise "Authorization definition '#{definition}' not found" unless definition_exists
end

Alors('je devrais être sur la page du tableau de bord') do
  expect(page).to have_current_path(%r{/tableau-de-bord})
end

Alors('je devrais être sur l\'espace administrateur') do
  expect(page).to have_current_path(admin_path)
end

Alors('la demande d\'habilitation doit être créée au nom de {string}') do |email|
  user = User.find_by(email: email)
  authorization_request = AuthorizationRequest.last
  expect(authorization_request.applicant).to eq(user)
end

Alors('une action d\'impersonation de type {string} doit être enregistrée pour {string}') do |action, model_type|
  impersonation_action = ImpersonationAction.last
  expect(impersonation_action).to be_present
  expect(impersonation_action.action).to eq(action)
  expect(impersonation_action.model_type).to eq(model_type)
end

Alors('je devrais voir {string}') do |content|
  expect(page).to have_content(content)
end

Alors('je ne devrais pas voir {string}') do |content|
  expect(page).to have_no_content(content)
end
