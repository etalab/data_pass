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
  # @param label [String] The visible text of the option to select
  # @param from [String] CSS selector or name of the multi-select container
  def select_multi_select_option(label, from:)
    container = find(from)
    option = container.find('.multi-select__option', text: label, visible: :all)
    option_value = option['data-multi-select-value-param']
    field_name = container['data-multi-select-name-value']

    # Find or create the hidden inputs container and add the input
    hidden_div = page.driver.browser.dom.at_css("##{container['id']} .multi-select__hidden-inputs")
    return unless hidden_div

    hidden_div.css("input[name='#{field_name}']").each(&:remove)
    hidden_div << Nokogiri::XML::Node.new('input', page.driver.browser.dom).tap do |input|
      input['type'] = 'hidden'
      input['name'] = field_name
      input['value'] = option_value
    end
  end
end
