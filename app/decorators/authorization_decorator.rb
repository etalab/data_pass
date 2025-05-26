class AuthorizationDecorator < ApplicationDecorator
  delegate_all

  decorates_association :request

  def name_for_select
    "Habilitation n°#{id} du #{formatted_date} : #{name}"
  end

  def translated_state
    I18n.t(state, scope: 'authorization.states', default: state)
  end

  def translated_state
    I18n.t(state, scope: 'authorization.states', default: state)
  end

  private

  def formatted_date
    I18n.l(created_at.to_date, format: :long)
  end
end
