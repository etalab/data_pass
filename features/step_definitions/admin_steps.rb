Quand("je me rends sur le module {string} de l'espace administrateur") do |path|
  visit "/admin/#{path.parameterize}"
end

Quand("je vais sur l'espace administrateur") do
  visit admin_path
end

Alors("je suis sur l'espace administrateur") do
  expect(page).to have_current_path(/admin/)
end

Alors('la page contient {int} utilisateurs') do |count|
  expect(page).to have_css('.user', count:)
end

Quand("je clique sur {string} pour l'utilisateur {string}") do |link, email|
  user = User.find_by(email:)

  within("#user_#{user.id}") do
    click_link_or_button link
  end
end

Quand("je remplis {string} avec l'ID de la demande") do |label|
  fill_in label, with: AuthorizationRequest.last.id
end

Soit("l'utilisateur {string}") do |email|
  @target_user = FactoryBot.create(:user, email:)
end

Soit("cet utilisateur appartient à l'organisation {string} avec le SIRET {string}") do |name, siret|
  organization = Organization.find_by(siret:) || FactoryBot.create(:organization, siret:, name:)
  @target_user.add_to_organization(organization, current: true)
end

Soit("cet utilisateur appartient à l'organisation {string} avec le SIRET {string} de manière vérifiée avec la raison {string}") do |name, siret, reason|
  organization = Organization.find_by(siret:) || FactoryBot.create(:organization, siret:, name:)
  @target_user.add_to_organization(organization, current: true, verified: true)
  organizations_user = @target_user.organizations_users.find_by(organization:)
  organizations_user.update!(verified_reason: reason)
end

Soit("cet utilisateur appartient à l'organisation {string} avec le SIRET {string} de manière non vérifiée") do |name, siret|
  organization = Organization.find_by(siret:) || FactoryBot.create(:organization, siret:, name:)
  @target_user.add_to_organization(organization, current: true, verified: false)
  organizations_user = @target_user.organizations_users.find_by(organization:)
  organizations_user.update!(verified_reason: 'manual')
end
