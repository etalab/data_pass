CUPRITE_DEFAULT_WINDOW_SIZE = [1024, 768].freeze

Quand('la fenêtre fait {int} pixels de large') do |width|
  page.driver.resize(width, CUPRITE_DEFAULT_WINDOW_SIZE.last)
  @window_resized = true
end

Alors('l’encadré de {string} s’affiche sous cette réponse') do |label|
  answer = find('.fr-fieldset__element', text: label)
  slot_after_answer = answer.find(:xpath, 'following-sibling::div[1]')

  expect(slot_after_answer).to have_css('.fr-callout', visible: :visible)
end

Alors('l’encadré s’affiche à droite des réponses') do
  expect(page).to have_css('[data-eligibility-result-target="aside"] .fr-callout', visible: :visible)
end

Alors('l’encadré est {string} avec l’icône {string}') do |color_class, icon_class|
  expect(page).to have_css(".fr-callout.#{color_class}.#{icon_class}", visible: :visible)
end

Alors('l’illustration est affichée') do
  expect(page).to have_css('.eligibility-illustration-container', visible: :visible)
end

Alors('l’illustration n’est pas affichée') do
  expect(page).to have_no_css('.eligibility-illustration-container', visible: :visible)
end

Alors('la réponse {string} est cochée') do |label|
  expect(page).to have_checked_field(label, visible: :all)
end

After do
  page.driver.resize(*CUPRITE_DEFAULT_WINDOW_SIZE) if @window_resized
end
