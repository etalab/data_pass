Sachantque('j\'impersonne l\'utilisateur {string}') do |email|
  visit new_admin_impersonate_path

  fill_in 'Email', with: email
  fill_in 'Raison', with: 'Test impersonation'
  click_button 'Commencer'
end

Alors('une action d\'impersonation de type {string} doit être enregistrée pour {string}') do |action, model_type|
  impersonation_action = ImpersonationAction.last
  expect(impersonation_action).to be_present
  expect(impersonation_action.action).to eq(action)
  expect(impersonation_action.model_type).to eq(model_type)
end
