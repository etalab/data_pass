Quand("je me rends sur la page d'accueil") do
  visit root_path
end

Quand('print the page') do
  log page.body
end

Alors('il y a un titre contenant {string}') do |text|
  element = page.all('h1').first ||
            page.all('table caption').first

  expect(element.text).to include(text)
end

Alors('je suis sur la page {string}') do |text|
  step "il y a un titre contenant \"#{text}\""
end

Quand('je clique sur {string}') do |label|
  click_link_or_button label # rubocop:disable Capybara/ClickLinkOrButtonStyle
end

Alors('la page contient {string}') do |content|
  expect(page).to have_content(content)
end

Alors('la page ne contient pas {string}') do |content|
  expect(page).not_to have_content(content)
end

Alors('la page contient {string} dans la rangée {string} du tableau {string}') do |content, row, caption|
  expect(page).to have_table(caption, with_rows: [row, content])
end

Alors('le tableau {string} contient') do |caption, table|
  expect(page).to have_table(caption, with_rows: table.rows)
end

Alors('le titre de la page contient {string}') do |text|
  expect(page.title.gsub('  ', ' ')).to include text
end

Quand('je remplis {string} avec {string}') do |label, value|
  fill_in label, with: value
end

Quand('je clique sur {string} dans la rangée {string}') do |link, row|
  within('tr', text: row) do
    click_link(link)
  end
end

Quand('je sélectionne {string} pour {string}') do |option, name|
  select option, from: name
end

Quand('je choisis {string}') do |option|
  choose option
end

Quand('je coche {string}') do |label|
  check label
end

Alors('je peux voir dans le tableau {string}') do |caption, table|
  expect(page).to have_table(caption, with_rows: table.rows)
end

Alors('je peux voir dans le tableau {string} dans cet ordre :') do |caption, table_data|
  within_table(caption) do
    table_data.rows.each_with_index do |row, row_number|
      row.each_with_index do |cel, cel_number|
        expect(find("tr[#{row_number + 1}]/td[#{cel_number + 1}]")).to have_text(cel)
      end
    end
  end
end

Alors("il n'y a pas de bouton {string}") do |label|
  expect(page).not_to have_button(label)
end

Alors('il y a un bouton {string}') do |label|
  expect(page).to have_button(label)
end

Alors('il y a un message de succès contenant {string}') do |text|
  expect(page).to have_css('.fr-alert.fr-alert--success', text:)
end

Alors("il y a un message d'erreur contenant {string}") do |text|
  expect(page).to have_css('.fr-alert.fr-alert--error', text:)
end

Alors("il y a un message d'attention contenant {string}") do |text|
  expect(page).to have_css('.fr-alert.fr-alert--warning', text:)
end

Alors('il y a au moins une erreur sur un champ') do
  expect(page).to have_css('.fr-input-group.fr-input-group--error')
end

Alors('debug') do
  byebug # rubocop:disable Lint/Debugger
end

Quand('je rafraîchis la page') do
  visit current_path
end

Quand(/je vais sur la page (des |du |de la |de mon )?(.*)/) do |_, page_name|
  visit "/#{page_name}"
end
