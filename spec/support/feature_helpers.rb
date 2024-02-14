module FeaturesHelpers
  include ActionView::RecordIdentifier

  def css_id(record, prefix = nil)
    "##{dom_id(record, prefix)}"
  end

  def input_identifier(klass, attribute)
    "#{klass.model_name.singular}_#{attribute}"
  end
end
