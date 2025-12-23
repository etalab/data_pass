module FeaturesHelpers
  include ActionView::RecordIdentifier

  def css_id(record, prefix = nil)
    "##{dom_id(record, prefix)}"
  end

  def input_identifier(klass, attribute)
    "#{klass.model_name.singular}_#{attribute}"
  end

  # Select an option from a multi-select component by label text
  # Works with JavaScript-disabled tests by directly adding hidden form inputs
  # Supports multiple selections - call multiple times to select multiple options
  # @param label [String] The visible text of the option to select
  # @param from [String] CSS selector or name of the multi-select container
  # rubocop:disable Metrics/AbcSize
  def select_multi_select_option(label, from:)
    container = find(from)
    option = container.find('.multi-select__option', text: label, visible: :all)
    option_value = option['data-multi-select-value-param']
    field_name = container['data-multi-select-name-value']

    # Find the hidden inputs container and add the input (don't remove existing ones for multi-select)
    hidden_div = page.driver.browser.dom.at_css("##{container['id']} .multi-select__hidden-inputs")
    return unless hidden_div

    # Only add if this value doesn't already exist
    existing = hidden_div.css("input[name='#{field_name}'][value='#{option_value}']")
    return if existing.any?

    hidden_div << Nokogiri::XML::Node.new('input', page.driver.browser.dom).tap do |input|
      input['type'] = 'hidden'
      input['name'] = field_name
      input['value'] = option_value
    end
  end
  # rubocop:enable Metrics/AbcSize
end
