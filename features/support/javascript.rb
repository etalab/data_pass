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

def wait_for_dsfr_collapse_button(element)
  collapse_id = element[:'aria-controls']
  return if collapse_id.blank? || page.has_no_selector?(:id, collapse_id, class: 'fr-collapse', visible: :all, wait: 0)

  raise "DSFR non initialisé sur ##{collapse_id}" unless element.matches_css?('[data-fr-js-collapse-button]')

  page.evaluate_async_script('requestAnimationFrame(() => requestAnimationFrame(arguments[0]))')
end
