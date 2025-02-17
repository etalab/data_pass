Alors('montre moi la page') do
  save_and_open_page # rubocop:disable Lint/Debugger
end

Quand('print the page') do
  log page.body
end

Alors('debug') do
  if javascript?
    page.driver.debug(binding)
  else
    byebug # rubocop:disable Lint/Debugger
  end
end
