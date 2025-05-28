class AuthorizationRequestDecorator < ApplicationDecorator
  delegate_all

  decorates_association :organization

  def to_partial_path
    'authorization_requests/card'
  end

  def date
    if reopening_validated?
      t('authorization_requests.card.created_and_udpated_at', created_date: l(created_at, format: '%d/%m/%Y'), updated_date: l(latest_authorization.created_at, format: '%d/%m/%Y'))
    elsif reopening?
      t('authorization_requests.card.reopened_at', reopened_date: l(reopened_at, format: '%d/%m/%Y'))
    else
      t('authorization_requests.card.created_at', created_date: l(created_at, format: '%d/%m/%Y'))
    end
  end

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

  def display_card_stage_footer? # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    return false unless definition.multi_stage?

    if definition.stage.type == 'sandbox'
      return false if (draft? || submitted?) && !any_next_stage_authorization_exists?
      return false if reopening? && !any_next_stage_authorization_exists?
      return false if reopening? && any_next_stage_authorization_exists? && (draft? || submitted?)
    else
      return false if reopening?
      return false if last_stage_request_without_previous_stages_authorizations? && (draft? || submitted?)
      return true if draft? || submitted?
      return false unless definition.next_stage?
    end

    validated? || submitted?
  end

  def last_stage_request_without_previous_stages_authorizations?
    authorization_request.authorizations.where.not(authorization_request_class: type).none?
  end

  def display_card_reopening_footer?
    if definition.multi_stage?
      !display_card_stage_footer? &&
        reopening?
    else
      reopening?
    end
  end

  def next_stage_already_started?
    return false unless definition.multi_stage?

    return false if definition.stage.type == 'sandbox'

    draft? || submitted?
  end

  def prefilled_data?(keys)
    return false if empty_form_data?

    form_data_keys = (object.form.initialize_with.keys - %i[scopes])
    keys = keys.map(&:to_sym)

    form_data_keys.intersect?(keys) ||
      prefilled_scopes?(keys)
  end

  def card_name
    base_card_name.truncate(50)
  end

  def applicant_details
    highlighted = object.applicant == h.current_user

    h.content_tag(:p, class: ['fr-card__detail', 'fr-icon-user-fill', { 'fr-text-title--blue-france': highlighted }]) do
      card_provider_applicant_details(h.current_user)
    end
  end

  def reopening_validated?
    object.authorizations.where(authorization_request_class: object.type).many?
  rescue NoMethodError
    false
  end

  def dirty_related_errors
    return [] unless object.dirty_from_v1?
    return [] if object.valid?(:submit)

    object.errors.reject { |e| e.type == :all_terms_not_accepted }
  end

  private

  def card_provider_applicant_details(user)
    if only_in_contacts?(user)
      current_user_is_a_contact(user)
    elsif object.applicant == user
      current_user_is_applicant
    else
      default_applicant_full_name
    end
  end

  def lookup_i18n_key(subkey)
    t("authorization_request_forms.#{object.model_name.element}.#{subkey}", default: nil) ||
      t("authorization_request_forms.default.#{subkey}")
  end

  def current_user_is_a_contact(user)
    t('authorization_requests.card.current_user_mentions', contact_types: humanized_contact_types_for(user).to_sentence)
  end

  def current_user_is_applicant
    t('authorization_requests.card.current_user_is_applicant')
  end

  def default_applicant_full_name
    t('authorization_requests.card.applicant_request', applicant_full_name: object.applicant.full_name)
  end

  def prefilled_scopes?(keys)
    return false unless object.form.initialize_with.key?(:scopes) && object.form.initialize_with[:scopes].present?

    keys.include?(:scopes) &&
      object.form.initialize_with[:scopes].any?
  end

  def empty_form_data?
    object.form.initialize_with.blank? ||
      object.form.initialize_with == { scopes: [] }
  end

  # rubocop:disable Metrics/AbcSize
  def base_card_name
    if object.data['intitule'].present?
      object.data['intitule']
    elsif object.form.name.present?
      object.form.name
    else
      object.definition.name
    end
  end
  # rubocop:enable Metrics/AbcSize
end
