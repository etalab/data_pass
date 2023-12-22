include ActionView::RecordIdentifier

def css_id(record)
  "##{dom_id(record)}"
end

def input_identifier(klass, attribute)
  "#{klass.model_name.singular}_#{attribute}"
end
