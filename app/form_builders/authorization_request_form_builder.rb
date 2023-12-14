class AuthorizationRequestFormBuilder < DSFRFormBuilder
  def hint_for(attribute)
    I18n.t("authorization_request_forms.#{@object.model_name.element}.#{attribute}.hint", default: nil) ||
      I18n.t("authorization_request_forms.default.#{attribute}.hint", default: nil) ||
      super(attribute)
  end

  def label_value(attribute)
    I18n.t("authorization_request_forms.#{@object.model_name.element}.#{attribute}.label", default: nil) ||
      I18n.t("authorization_request_forms.default.#{attribute}.label", default: nil) ||
      super(attribute)
  end

  def dsfr_file_field(attribute, opts = {})
    dsfr_input_group(attribute, opts) do
      @template.safe_join(
        [
          label_with_hint(attribute),
          readonly? ? nil : file_field(attribute, class: input_classes(opts), autocomplete: 'off', **enhance_input_options(opts).except(:class)),
          error_message(attribute),
          link_to_file(attribute)
        ].compact
      )
    end
  end

  def link_to_file(attribute)
    link_to_file = super(attribute)

    if link_to_file.present?
      link_to_file
    elsif readonly?
      I18n.t('form.no_file')
    else
      ''
    end
  end

  def enhance_input_options(opts)
    super.merge(readonly: readonly?)
  end

  def readonly?
    !@object.in_draft?
  end
end
