Quand("je vais sur l'espace administrateur") do
  visit admin_path
end

Alors("je suis sur l'espace administrateur") do
  expect(page).to have_current_path(/admin/)
end
