load Rails.root.join('spec/support/configure_javascript_driver.rb')

Before do |scenario|
  if $app_host_overridden
    Capybara.app_host = $previous_app_host
    $previous_app_host = nil
    $app_host_overridden = false
  end

  @javascript = scenario.source_tag_names.include?('@javascript')
end

def javascript?
  @javascript
end
