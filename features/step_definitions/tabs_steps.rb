Alors("je vois l'onglet {string}") do |tab_name|
  expect(page).to have_css('.fr-tabs__tab', text: tab_name)
end

Alors("je ne vois pas l'onglet {string}") do |tab_name|
  expect(page).to have_no_css('.fr-tabs__tab', text: tab_name)
end
