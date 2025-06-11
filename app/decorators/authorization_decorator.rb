class AuthorizationDecorator < ApplicationDecorator
  delegate_all

  decorates_association :request

  def name_for_select
    "Habilitation n°#{id} du #{formatted_date} : #{name}"
  end

  def translated_state
    I18n.t(state, scope: 'authorization.states', default: state)
  end

  def state_badge_html_class
    case state
    when 'revoked' then 'fr-badge--error'
    when 'active' then 'fr-badge--success'
    else ''
    end
  end

  private

  def formatted_date
    I18n.l(created_at.to_date, format: :long)
  end
end
