class AuthorizationDecorator < ApplicationDecorator
  delegate_all

  def name_for_select
    "Habilitation du #{slug} : #{name}"
  end
end
