Quand('je visite la page des stats avec les paramètres {string}') do |query_params|
  visit "/stats?#{query_params}"
end

Alors('je vois un champ de date pour la période de début') do
  expect(page).to have_field('startDate', type: 'date')
end

Alors('je vois un champ de date pour la période de fin') do
  expect(page).to have_field('endDate', type: 'date')
end
