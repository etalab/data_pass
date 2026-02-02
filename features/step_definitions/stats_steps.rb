Quand('je visite {string}') do |path|
  visit path
end

Alors('je vois {string}') do |text|
  expect(page).to have_content(text)
end

Alors('je vois un champ de date pour la période de début') do
  expect(page).to have_field('startDate', type: 'date')
end

Alors('je vois un champ de date pour la période de fin') do
  expect(page).to have_field('endDate', type: 'date')
end

Alors('je vois un sélecteur de dimension') do
  expect(page).to have_select(visible: :visible)
  expect(page).to have_content('Statistiques par')
end
