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
