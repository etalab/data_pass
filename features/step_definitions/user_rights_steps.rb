Quand('je me rends sur la page de gestion des droits') do
  visit user_rights_index_path_for(current_user!)
end

Quand("je me rends sur la page d'ajout de droits") do
  visit new_user_right_path_for(current_user!)
end

def user_rights_index_path_for(user)
  user.admin? ? admin_user_rights_path : instruction_user_rights_path
end

def new_user_right_path_for(user)
  user.admin? ? new_admin_user_right_path : new_instruction_user_right_path
end

def edit_user_right_path_for(user, target)
  user.admin? ? edit_admin_user_right_path(target) : edit_instruction_user_right_path(target)
end

def confirm_destroy_user_right_path_for(user, target)
  user.admin? ? confirm_destroy_admin_user_right_path(target) : confirm_destroy_instruction_user_right_path(target)
end

Alors('la page ne contient pas mon email') do
  expect(page).to have_no_text(current_user!.email)
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

Quand('je sélectionne {string} pour {string} dans le {string}') do |option, name, legend|
  within('fieldset', text: legend) do
    select option, from: name
  end
end

Alors('le tableau des utilisateurs contient {string}') do |email|
  within('#user-rights-table') do
    expect(page).to have_text(email)
  end
end

Alors('le tableau des utilisateurs ne contient pas {string}') do |email|
  within('#user-rights-table') do
    expect(page).to have_no_text(email)
  end
end

Alors('le tableau des utilisateurs contient le badge {string}') do |label|
  within('#user-rights-table') do
    expect(page).to have_css('p.fr-badge', text: label)
  end
end

Alors('la section des droits non modifiables indique {string}') do |message|
  within('#readonly-rights') do
    expect(page).to have_text(message)
  end
end

Alors('le fil d’Ariane contient un lien {string} vers la page de gestion des droits admin') do |label|
  within('.fr-breadcrumb') do
    expect(page).to have_link(label, href: admin_user_rights_path)
  end
end

Quand('je tente de modifier mes propres droits via URL') do
  visit edit_user_right_path_for(current_user!, current_user!)
end

Quand('je tente de modifier les droits de {string} via URL') do |email|
  user = User.find_by!(email:)
  visit edit_user_right_path_for(current_user!, user)
end

Quand('je tente d’accéder à la confirmation de suppression de mes propres droits via URL') do
  visit confirm_destroy_user_right_path_for(current_user!, current_user!)
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

Alors('le champ de recherche porte les attributs de focus et d’auto-soumission') do
  expect(page).to have_css('input[type="search"][autofocus]')
  expect(page).to have_css("form[data-auto-submit-form-debounce-interval-value='800']")
end

Alors('le tableau des utilisateurs contient mon email') do
  within('#user-rights-table') do
    expect(page).to have_text(current_user!.email)
  end
end

Alors('la zone de statut de recherche annonce {string}') do |message|
  expect(page).to have_css('[role="status"]', text: message)
end

Alors('ma ligne n’affiche aucun bouton de modification ni de suppression') do
  within("##{ActionView::RecordIdentifier.dom_id(current_user!)}") do
    expect(page).to have_no_css('.fr-icon-edit-line')
    expect(page).to have_no_css('.fr-icon-delete-line')
  end
end

Alors('ma ligne affiche un bouton de modification') do
  within("##{ActionView::RecordIdentifier.dom_id(current_user!)}") do
    expect(page).to have_css('.fr-icon-edit-line')
  end
end
