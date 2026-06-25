class Instruction::AuthorizationDefinitionPolicy < ApplicationPolicy
  def index?
    user.reporter? && feature_flag_show_definitions?
  end

  def feature_flag_show_definitions?
    user.admin? || Rails.env.test?
  end
end
