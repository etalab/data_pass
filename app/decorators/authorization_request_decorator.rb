class AuthorizationRequestDecorator < ApplicationDecorator
  delegate_all

  decorates_association :organization

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

  def contact_full_name(contact_type)
    [
      object.data["#{contact_type}_given_name"],
      object.data["#{contact_type}_family_name"],
    ].compact.join(' ')
  end

  def contact_data_by_type(contact_type)
    {
      email: object.data["#{contact_type}_email"],
      job_title: object.data["#{contact_type}_job_title"],
      given_name: object.data["#{contact_type}_given_name"],
      family_name: object.data["#{contact_type}_family_name"],
      phone_number: object.data["#{contact_type}_phone_number"],
    }
  end

  def skip_contact_attribute?(contact_type, contact_attribute)
    model.public_send(:"#{contact_type}_type") == 'organization' &&
      %w[family_name given_name job_title].include?(contact_attribute)
  end

  private

  def lookup_i18n_key(subkey)
    t("authorization_request_forms.#{object.model_name.element}.#{subkey}", default: nil) ||
      t("authorization_request_forms.default.#{subkey}")
  end
end
