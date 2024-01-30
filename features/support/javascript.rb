load Rails.root.join('spec/support/configure_javascript_driver.rb')

Before do |scenario|
  @javascript = scenario.source_tag_names.include?('@javascript')
end

def javascript?
  @javascript
end
