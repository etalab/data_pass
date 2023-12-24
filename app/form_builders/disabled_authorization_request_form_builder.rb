class DisabledAuthorizationRequestFormBuilder < AuthorizationRequestFormBuilder
  def readonly?
    true
  end

  def dsfr_select_tag(attribute, _choices, opts)
    text_field(attribute, class: input_classes(opts), autocomplete: 'off', **enhance_input_options(opts).except(:class))
  end
end
