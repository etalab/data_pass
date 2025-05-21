class AuthorizationDecorator < ApplicationDecorator
  delegate_all

  def name_for_select
    "Habilitation n°#{id} du #{formatted_date} : #{name}"
  end

  private

  def formatted_date
    I18n.l(created_at.to_date, format: :long)
  end
end
