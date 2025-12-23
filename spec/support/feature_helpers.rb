module FeaturesHelpers
  include ActionView::RecordIdentifier

  def css_id(record, prefix = nil)
    "##{dom_id(record, prefix)}"
  end

  def input_identifier(klass, attribute)
    "#{klass.model_name.singular}_#{attribute}"
  end

  # Select an option from a multi-select component by label text
  # Uses the native <select multiple> fallback that works without JavaScript
  # Supports multiple selections - call multiple times to select multiple options
  # @param label [String] The visible text of the option to select
  # @param from [String] CSS selector of the multi-select container
  def select_multi_select_option(label, from:)
    container = find(from)
    native_select = container.find('.dsfrx-multiselect__native', visible: :all)
    native_select.select(label)
  end
end
