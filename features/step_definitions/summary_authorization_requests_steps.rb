def summary_block_testing(block_title, &)
  attempts = 0

  begin
    attempts += 1
    summary_title = find('.summary-block__title', text: block_title, wait: 10)
    summary_block = find(".summary-block[aria-labelledby='#{summary_title[:id]}']", wait: 10)

    within(summary_block, &)
  rescue Capybara::Cuprite::ObsoleteNode, Ferrum::BrowserError
    retry if attempts < 3

    raise
  end
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

Alors('il y a {string} dans le bloc de résumé {string}') do |text, block_title|
  summary_block_testing(block_title) do
    expect(page).to have_text(text)
  end
end
