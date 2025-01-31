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
