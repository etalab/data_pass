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
end
