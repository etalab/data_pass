class AuthorizationDecorator < ApplicationDecorator
  delegate_all

  decorates_association :request

  def card_name
    base_card_name.truncate(50)
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

  private

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
    t('dashboard.card.authorization_request_card.current_user_mentions', definition_name: object.definition.name, contact_types: humanized_contact_types_for(user).to_sentence)
  end

  def current_user_is_applicant
    t('dashboard.card.authorization_request_card.current_user_is_applicant', definition_name: object.definition.name)
  end

  def default_applicant_full_name
    t('dashboard.card.authorization_request_card.applicant_request', definition_name: object.definition.name, applicant_full_name: object.applicant.full_name)
  end


  def formatted_date
    I18n.l(created_at.to_date, format: :long)
  end
end
