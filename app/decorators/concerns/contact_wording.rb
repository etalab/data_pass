module ContactWording
  def humanized_contact_types_for(user)
    object.contact_types_for(user).map do |contact_type|
      contact_mention(contact_type)
    end
  end

  private

  def contact_mention(contact_type)
    t("authorization_request_forms.#{request_model_element}.#{contact_type}.mention", default: nil) ||
      lookup_i18n_key("#{contact_type}.title").downcase
  end

  def lookup_i18n_key(subkey)
    t("authorization_request_forms.#{request_model_element}.#{subkey}", default: nil) ||
      t("authorization_request_forms.default.#{subkey}")
  end
end
