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

  def skip_contact_attribute?(contact_type, contact_attribute)
    model.public_send(:"#{contact_type}_type") == 'organization' &&
      %w[family_name given_name job_title].include?(contact_attribute)
  end

  def contact_info(contact_type)
    t("authorization_request_forms.#{object.form.id.underscore}.#{contact_type}.info", default: nil) ||
      t("authorization_request_forms.#{object.model_name.element}.#{contact_type}.info", default: nil) ||
      t("authorization_request_forms.default.#{contact_type}.info", default: nil)
  end

  def prefilled_data?
    return false unless form.multiple_steps?

    object.form.steps.all? { |step| data_present_for_step?(step) }
  end

  private

  def data_present_for_step?(step)
    return false if form.data.nil?

    data.present? && !data_empty?(data, %w[scopes intitule description volumetrie_approximative date_prevue_mise_en_production])
  end

  def data_empty?(data, attributes = %w[scopes intitule description volumetrie_approximative date_prevue_mise_en_production])
    attributes.all? { |attr| data[attr].blank? }
  end

  def lookup_i18n_key(subkey)
    t("authorization_request_forms.#{object.model_name.element}.#{subkey}", default: nil) ||
      t("authorization_request_forms.default.#{subkey}")
  end
end
