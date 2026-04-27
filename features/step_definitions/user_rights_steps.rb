Quand('je me rends sur la page de gestion des droits') do
  visit instruction_user_rights_path
end

Quand("je me rends sur la page d'ajout de droits") do
  visit new_instruction_user_right_path
end

Alors('la page ne contient pas mon email') do
  expect(page).to have_no_content(current_user!.email)
end

Alors("l'utilisateur {string} a les rôles {string}") do |email, roles|
  user = User.find_by!(email:)
  expect(user.roles).to match_array(roles.split(',').map(&:strip))
end

Alors('le select {string} contient {string}') do |select_name, option|
  expect(page).to have_select(select_name, with_options: [option])
end

Alors('le select {string} ne contient pas {string}') do |select_name, option|
  expect(page).to have_no_select(select_name, with_options: [option])
end

Alors('le select {string} est positionné sur {string}') do |select_name, option|
  expect(page).to have_select(select_name, selected: option)
end

Alors('le champ {string} est en lecture seule') do |label|
  expect(page).to have_field(label, readonly: true)
end

Quand('je tente de modifier mes propres droits via URL') do
  visit edit_instruction_user_right_path(current_user!)
end

Quand('je tente de modifier les droits de {string} via URL') do |email|
  user = User.find_by!(email:)
  visit edit_instruction_user_right_path(user)
end

Quand('je tente d’accéder à la confirmation de suppression de mes propres droits via URL') do
  visit confirm_destroy_instruction_user_right_path(current_user!)
end

Sachantque('je suis un manager de tout {string}') do |provider_slug|
  email = "fd-manager-#{provider_slug}@gouv.fr"
  user = User.find_by(email:) || FactoryBot.create(:user, email: email)
  user.revoke_all_roles
  user.grant_fd_role(:manager, provider_slug)
  user.save!

  @current_user_email = user.email
  mock_identity_federators(user)
end

Quand("il y a l'utilisateur {string} avec le rôle brut {string}") do |email, raw_role|
  user = User.find_by(email:) || FactoryBot.create(:user, email: email)
  user.roles << raw_role
  user.roles.uniq!
  user.save!
end

Alors('la page ne contient pas le champ {string}') do |label|
  expect(page).to have_no_field(label)
end

Alors('le titre principal de la page contient {string}') do |text|
  expect(page).to have_css('h1', text: text)
end

Alors("la page contient l'accordéon {string} replié par défaut") do |title|
  button = find('.fr-accordion__btn', text: title)
  expect(button['aria-expanded']).to eq('false')
end
