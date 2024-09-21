Quand('il y a une modale contenant {string}') do |text|
  expect(page).to have_css('.fr-modal', text:, visible: javascript?)
end

Quand("il n'y a pas de modale contenant {string}") do |text|
  expect(page).to have_no_selector('.fr-modal', text:, visible: javascript?)
end
