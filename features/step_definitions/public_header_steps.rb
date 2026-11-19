Alors("l'en-tête contient {string}") do |text|
  within('#header') do
    expect(page).to have_text(text)
  end
end

Alors("l'en-tête contient le lien {string}") do |label|
  within('#header') do
    expect(page).to have_link(label)
  end
end

Alors("l'en-tête ne contient pas le lien {string}") do |label|
  within('#header') do
    expect(page).to have_no_link(label)
  end
end

Alors('la page contient un lien {string} vers {string}') do |label, href|
  expect(page).to have_link(label, href:)
end

Alors('la tuile {string} mène à {string}') do |title, href|
  within('.fr-tile', text: title) do
    expect(page).to have_link(title, href:)
  end
end

Quand('je compte les visites Turbo') do
  page.execute_script(<<~JS)
    window.turboVisits = 0
    document.addEventListener('turbo:visit', () => { window.turboVisits += 1 })
  JS
end

Quand('je clique deux fois sur la tuile {string}') do |title|
  2.times do
    within('.fr-tile', text: title) { click_link(title) }
  end
end

Alors("l'adresse se termine par {string}") do |hash|
  expect(page.evaluate_script('window.location.hash')).to eq(hash)
end

Alors("Turbo n'a lancé aucune visite") do
  expect(page.evaluate_script('window.turboVisits')).to eq(0)
end

Alors('l’accueil n’affiche pas de bandeau d’information') do
  expect(page).to have_no_css('.fr-notice')
end
