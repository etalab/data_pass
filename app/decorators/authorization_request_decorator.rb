class AuthorizationRequestDecorator < ApplicationDecorator
  delegate_all

  def only_in_contacts?(user)
    user != object.applicant &&
      object.contact_types_for(user).present?
  end

  def humanized_contact_types_for(user)
    object.contact_types_for(user).map do |contact_type|
      lookup_i18n_key("#{contact_type}.title").downcase
    end
  end

  def editable_blocks
    blocks.select do |block|
      object.form.static_blocks.pluck(:name).exclude?(block[:name])
    end
  end

  def static_blocks
    blocks - editable_blocks
  end

  def blocks
    object.definition.blocks
  end

  private

  def lookup_i18n_key(subkey)
    t("authorization_request_forms.#{object.model_name.element}.#{subkey}", default: nil) ||
      t("authorization_request_forms.default.#{subkey}")
  end
end
