load Rails.root.join('spec/support/configure_javascript_driver.rb')

Before do |scenario|
  if $previous_app_host
    Capybara.app_host = $previous_app_host
    $previous_app_host = nil
  end

  @javascript = scenario.source_tag_names.include?('@javascript')
end

def javascript?
  @javascript
end
