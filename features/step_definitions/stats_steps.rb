Quand('je visite la page des stats avec les paramètres {string}') do |query_params|
  visit "/stats?#{query_params}"
end

Alors('la page des stats affiche le titre principal') do
  expect(page).to have_content(I18n.t('stats.index.page_heading'), normalize_ws: true)
end

Alors('je vois un champ de date pour la période de début') do
  expect(page).to have_field('start-date', type: 'date')
end

Alors('je vois un champ de date pour la période de fin') do
  expect(page).to have_field('end-date', type: 'date')
end

Alors('la page affiche l\'erreur de plage de dates') do
  expect(page).to have_content(I18n.t('stats.errors.start_before_end'), normalize_ws: true)
end

Quand('je clique sur la plage rapide {string}') do |label|
  click_link_or_button label
end

Alors('les champs de date de la page des stats sont renseignés') do
  expect(page).to have_field('start-date', type: 'date', with: /.+/)
  expect(page).to have_field('end-date', type: 'date', with: /.+/)
end
