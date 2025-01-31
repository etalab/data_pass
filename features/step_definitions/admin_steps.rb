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
