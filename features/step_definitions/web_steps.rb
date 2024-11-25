Quand("je me rends sur la page d'accueil") do
  visit root_path
end

Quand('print the page') do
  log page.body
end

Alors('il y a un titre contenant {string}') do |text|
  elements = [
    page.all('h1').first,
    page.all('p.fr-h2').first,
    page.all('h2').first,
    page.all('table caption').first,
  ]

  expect(elements.any? { |element| element&.text&.include?(text) }).to be_truthy
end

Alors('je suis sur la page {string}') do |text|
  step "il y a un titre contenant \"#{text}\""
end

Quand(/je clique sur (le (?:dernier|premier) )?"([^"]+)"\s*$/) do |position, label|
  case position
  when 'le dernier '
    page.all('a', text: label).last.click
  when 'le premier '
    page.all('a', text: label).first.click
  else
    if javascript?
      find(:link_or_button, label).trigger('click')
    else
      click_link_or_button label
    end
  end
end

Alors('la page contient {string}') do |content|
  expect(page).to have_content(content)
end

Alors('la page contient un lien vers {string}') do |domain|
  expect(page).to have_link(nil, href: /#{domain}/)
end

Alors('la page ne contient aucun lien vers {string}') do |domain|
  expect(page).to have_no_link(nil, href: /#{domain}/)
end

Alors('la page ne contient pas {string}') do |content|
  expect(page).to have_no_content(content)
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
  if javascript?
    node = find_field(label)

    value.chars.each do |char|
      node.send_keys(char)
    end
  else
    fill_in label, with: value
  end
end

Quand('je remplis {string} avec le fichier {string}') do |label, path|
  attach_file(label, path)
end

Quand('je clique sur {string} dans la rangée {string}') do |link, row|
  within('tr', text: row) do
    click_link_or_button(link)
  end
end

Quand('je sélectionne {string} pour {string}') do |option, name|
  if javascript?
    select(option, from: name).trigger('click')
  else
    select option, from: name
  end
end

Quand('je choisis {string}') do |option|
  if javascript?
    find('label', text: option)&.click
  else
    choose option
  end
end

Quand('je coche {string}') do |label|
  if javascript?
    find('label', text: label, visible: :all)&.click
  else
    check label
  end
end

Alors('{string} est coché') do |label|
  expect(page).to have_checked_field(label)
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
  element_found = page.has_button?(label) || page.has_link?(label)

  expect(element_found).to be_falsey, "Expected to not find a button or link with the label '#{label}', found at least one"
end

Alors('il y a un bouton {string}') do |label|
  expect(page).to have_button(label)
rescue RSpec::Expectations::ExpectationNotMetError
  expect(page).to have_link(label)
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

Alors("il y a un message d'info contenant {string}") do |text|
  expect(page).to have_css('.fr-alert.fr-alert--info', text:)
end

Alors("il n'y a pas de message d'alerte contenant {string}") do |text|
  expect(page).to have_no_css('.fr-alert', text:)
end

Alors('il y a une mise en avant contenant {string}') do |text|
  expect(page).to have_css('.fr-callout', text:)
end

Alors('il y a au moins une erreur sur un champ') do
  expect(page).to have_css('.fr-input-group.fr-input-group--error')
end

Alors('il y a une erreur {string} sur le champ {string}') do |error, field|
  node = find_field(field).find(:xpath, '..')
  expect(node).to have_css('.fr-error-text', text: error)
end

Alors('debug') do
  if javascript?
    page.driver.debug(binding)
  else
    byebug # rubocop:disable Lint/Debugger
  end
end

Quand(/wait (\d+)/) do |seconds|
  sleep seconds.to_i
end

Quand('je rafraîchis la page') do
  visit current_path
end

Quand(/je vais sur la page (des |du |de la |de mon )?(.*)/) do |_, page_name|
  visit "/#{page_name.tr(' ', '-')}"
end

Quand('je me rends sur mon tableau de bord') do
  visit dashboard_path
end

Alors("il n'y a pas de champ éditable") do
  all('input').each do |input|
    expect(input).to be_readonly if %w[hidden checkbox].exclude?(input[:type])
  end
end

# https://rubular.com/r/xHZlGXKvtnqUvz
Alors(/je vois( au moins)? (\d+) (tuiles?|cartes?)(?: "([^"]+)")?/) do |at_least, count, kind, text|
  kind_to_selector = {
    'tuile' => '.fr-tile',
    'carte' => '.fr-card',
  }

  css = kind_to_selector[kind.singularize]

  options = if at_least.present?
              { minimum: count.to_i }
            else
              { count: count.to_i }
            end

  options[:text] = text if text.present?

  expect(page).to have_css(css, **options)
end

Alors('il y a un badge {string}') do |text|
  expect(page).to have_css('.fr-badge', text:)
end

Alors('la page contient le logo du fournisseur de données {string}') do |authorization_definition|
  provider_logo = find_authorization_definition_from_name(authorization_definition).provider.name
  expect(page).to have_xpath("//img[contains(@alt, \"#{provider_logo}\")]")
end

Alors('je ne peux pas cocher {string}') do |checkbox_label|
  checkbox_id = "##{find('label', text: checkbox_label)[:for]}"

  expect(page.find(checkbox_id, visible: :all)[:disabled]).to be_truthy, "Expected checkbox '#{checkbox_label}' to be disabled"
end

Alors('je peux cocher {string}') do |checkbox_label|
  checkbox_id = "##{find('label', text: checkbox_label)[:for]}"

  expect(page.find(checkbox_id, visible: :all)[:disabled]).to be_in([nil, false]), "Expected checkbox '#{checkbox_label}' to be enabled"
end

Alors('un champ contient {string}') do |text|
  expect(all('input').any? { |input| input.value == text }).to be_truthy, "Expected to find a field with value '#{text}'"
end

Et('je peux voir le bouton {string} grisé et désactivé') do |string|
  expect(page).to have_css('button[disabled]', text: string)
end

Alors('il y a un lien vers {string}') do |url|
  expect(page).to have_link(href: url)
end

Alors('le lien de téléchargement de pièce jointe est désactivé') do
  expect(page).to have_css('a[aria-disabled="true"]', text: 'dummy.pdf')
end
