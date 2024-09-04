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

  def blocks
    @blocks ||= begin
      static_block_names = object.form.static_blocks.pluck(:name)

      object.definition.blocks.map do |block|
        block.merge(editable: static_block_names.exclude?(block[:name]))
      end
    end
  end

  def editable_blocks
    blocks.select { |block| block[:editable] }
  end

  def static_blocks
    blocks - editable_blocks
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

  def display_prefilled_banner_for_each_block?
    object.form.multiple_steps?
  end

  def prefilled_data?(keys)
    object.form.data.keys.intersect?(keys.map(&:to_sym))
  end

  def truncated_name(length)
    object.name.truncate(length)
  end

  def card_provider_applicant_details(user)
    if only_in_contacts?(user)
      current_user_is_a_contact(user)
    elsif object.applicant == user
      current_user_is_applicant
    else
      default_applicant_full_name
    end
  end

  private

  def lookup_i18n_key(subkey)
    t("authorization_request_forms.#{object.model_name.element}.#{subkey}", default: nil) ||
      t("authorization_request_forms.default.#{subkey}")
  end

  def current_user_is_a_contact(user)
    t('dashboard.card.authorization_request_card.current_user_mentions', definition_name: object.definition.name, contact_types: humanized_contact_types_for(user).to_sentence)
  end

  def current_user_is_applicant
    t('dashboard.card.authorization_request_card.current_user_is_applicant', definition_name: object.definition.name)
  end

  def default_applicant_full_name
    t('dashboard.card.authorization_request_card.applicant_request', definition_name: object.definition.name, applicant_full_name: object.applicant.full_name)
  end
end
