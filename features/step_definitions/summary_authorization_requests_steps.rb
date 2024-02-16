def summary_block_testing(block_title, &)
  summary_block = find('.summary-block__title', text: block_title).ancestor('.summary-block')

  within(summary_block, &)
end

Quand('je clique sur {string} dans le bloc de résumé {string}') do |button_text, block_title|
  summary_block_testing(block_title) do
    click_link_or_button button_text
  end
end

Alors('il y a un lien {string} dans le bloc de résumé {string}') do |button_text, block_title|
  summary_block_testing(block_title) do
    expect(page).to have_link(button_text)
  end
end

Alors("il n'y a pas de lien {string} dans le bloc de résumé {string}") do |button_text, block_title|
  summary_block_testing(block_title) do
    expect(page).to have_no_link(button_text)
  end
end
