Sachantque('le registre du portefeuille européen est ouvert') do
  @registry_open_before_scenario = ENV.fetch('EUROPEAN_WALLET_REGISTRY_OPEN', nil)
  ENV['EUROPEAN_WALLET_REGISTRY_OPEN'] = 'true'
end

After('@registre_ouvert') do
  ENV['EUROPEAN_WALLET_REGISTRY_OPEN'] = @registry_open_before_scenario
end

Alors('le fil d’Ariane mène de « {} » à « {} »') do |home, current|
  within('.fr-breadcrumb') do
    expect(page).to have_link(home, href: '/')
    expect(page).to have_css('[aria-current]', text: current)
  end
end

Alors('l’entrée du menu « {} » est la page courante') do |label|
  expect(page).to have_css('.fr-nav__link[aria-current="page"]', text: label)
end

Alors('les sections de la page se suivent dans cet ordre :') do |table|
  titles = page.all('#content h1, #content h2').map(&:text)

  expect(titles).to eq(table.raw.flatten)
end

Alors('la page ne contient pas de lien {string}') do |label|
  expect(page).to have_no_link(label)
end

Alors("l'en-tête contient un lien {string} vers {string}") do |label, href|
  within('#header') do
    expect(page).to have_link(label, href:)
  end
end

Alors('l’encart de l’accueil mène à {string}') do |href|
  within('#portefeuille-europeen') do
    expect(page).to have_link('Découvrir le registre du portefeuille européen', href:)
  end
end

Alors('l’onglet « Organisations » contient une mise en avant {string}') do |text|
  within('#tab-organisations-panel') do
    expect(page).to have_css('.fr-callout', text:)
  end
end

Alors('l’onglet « {} » est sélectionné') do |label|
  expect(page).to have_css('.fr-tabs__tab[aria-selected="true"]', text: label)
end

Alors('le bloc « Être prévenu » ne contient pas de formulaire et son champ d’adresse n’a pas de nom') do
  within('#etre-prevenu') do
    expect(page).to have_no_css('form')
    expect(page).to have_field('Votre adresse électronique', type: 'email')
    expect(page).to have_no_css('input[type="email"][name]')
  end
end
