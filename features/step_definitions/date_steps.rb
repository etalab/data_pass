Alors('la page contient la date du jour au format court') do
  expect(page).to have_content(Time.zone.today.strftime('%d/%m/%Y'))
end
