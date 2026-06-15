Alors("je suis sur l'espace instruction") do
  expect(page).to have_current_path(/instruction/)
end

Quand('je me rends sur la liste des formulaires') do
  visit instruction_data_providers_path
end

Alors('le menu de navigation contient {string}') do |text|
  within('#navigation-header-menu') do
    expect(page).to have_text(text)
  end
end
