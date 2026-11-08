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
