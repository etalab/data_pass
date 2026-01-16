Alors("je vois l'onglet {string}") do |tab_name|
  expect(page).to have_css('.fr-tabs__tab', text: tab_name)
end
