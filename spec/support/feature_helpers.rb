module FeaturesHelpers
  include ActionView::RecordIdentifier

  def css_id(record, prefix = nil)
    "##{dom_id(record, prefix)}"
  end

  def input_identifier(klass, attribute)
    "#{klass.model_name.singular}_#{attribute}"
  end

  # Select an option from a multi-select component by label text
  # @param label [String] The visible text of the option to select
  # @param from [String] CSS selector or name of the multi-select container
  def select_multi_select_option(label, from:)
    # Find the multi-select container
    container = find(from)

    # Click the trigger button to open the dropdown
    container.find('.multi-select__trigger').click

    # Wait for the dropdown to be visible and click the option
    within(container) do
      find('.multi-select__option', text: label).click
    end
  end
end
