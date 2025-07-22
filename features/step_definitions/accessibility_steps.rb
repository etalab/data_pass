Alors("je dois voir des liens d'évitement") do
  expect(page).to have_css('.fr-skiplinks')
  expect(page).to have_css('.fr-skiplinks__list li')
end

Alors("le lien d'évitement {string} doit mener à l'élément {string}") do |link_text, element_selector|
  skip_link = find('.fr-skiplinks__list a', text: link_text, visible: :all)

  expect(skip_link[:href]).to end_with(element_selector)

  target_selector = element_selector.sub(/^#/, '')
  expect(page).to have_css("[id='#{target_selector}']")
end
