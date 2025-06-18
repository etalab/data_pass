class AuthorizationDecorator < ApplicationDecorator
  delegate_all

  decorates_association :request

  def to_partial_path
    'authorizations/card'
  end

  def background_color_class
    return 'fr-background-action-high--blue-france' if active?

    'fr-background-alt--grey'
  end

  def color_class
    return 'fr-text-inverted--blue-france' if active?

    ''
  end

  def title
    t('authorizations.card.title', definition_name: object.definition.name).truncate(50)
  end

  def name
    model.name.truncate(50)
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

  def card_provider_applicant_details(user)
    if only_in_contacts?(user)
      current_user_is_a_contact(user)
    elsif object.applicant == user
      current_user_is_applicant
    else
      default_applicant_full_name
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

  def lookup_i18n_key(subkey)
    t("authorization_request_forms.#{object.model_name.element}.#{subkey}", default: nil) ||
      t("authorization_request_forms.default.#{subkey}")
  end

  def reopening_validated?
    object.request.authorizations.where(authorization_request_class: object.authorization_request_class).count > 1
  rescue NoMethodError
    false
  end

  def name_for_select
    "Habilitation n°#{id} du #{formatted_date} : #{name}"
  end

  def translated_state
    I18n.t(state, scope: 'authorization.states', default: state)
  end

  def status_badge(no_icon: false, scope: nil)
    h.content_tag(
      :span,
      t(status_badge_translation(scope)),
      class: [
        'fr-ml-1w',
        'fr-badge',
        no_icon ? 'fr-badge--no-icon' : nil,
      ]
        .concat(status_badge_class)
        .compact,
    )
  end

  def status_badge_class
    case state
    when 'active'
      %w[fr-badge--success]
    when 'revoked'
      %w[fr-badge--error]
    when 'obsolete'
      %w[fr-badge--secondary]
    end
  end

  private

  def status_badge_translation(scope)
    case scope
    when :instruction, 'instruction'
      "instruction.authorization_requests.index.status.#{state}"
    else
      "authorization_request.status.#{state}"
    end
  end


  # rubocop:disable Metrics/AbcSize
  def base_card_name
    if object.data['intitule'].present?
      object.data['intitule']
    elsif object.request.form.name.present?
      object.request.form.name
    else
      object.definition.name
    end
  end
  # rubocop:enable Metrics/AbcSize

  def current_user_is_a_contact(user)
    t('authorizations.card.current_user_mentions', contact_types: humanized_contact_types_for(user).to_sentence)
  end

  def current_user_is_applicant
    t('authorizations.card.current_user_is_applicant')
  end

  def default_applicant_full_name
    t('authorizations.card.applicant_request', applicant_full_name: object.applicant.full_name)
  end

  def formatted_date
    I18n.l(created_at.to_date, format: :long)
  end
end
