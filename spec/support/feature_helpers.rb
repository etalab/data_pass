module FeaturesHelpers
  include ActionView::RecordIdentifier

  def css_id(record, prefix = nil)
    "##{dom_id(record, prefix)}"
  end

  def input_identifier(klass, attribute)
    "#{klass.model_name.singular}_#{attribute}"
  end

  def select_multi_select_option(label, from:)
    container = find(from)
    native_select = container.find('.dsfrx-multiselect__native', visible: :all)
    native_select.select(label)
  end
end
