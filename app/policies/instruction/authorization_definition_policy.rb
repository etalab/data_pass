class Instruction::AuthorizationDefinitionPolicy < ApplicationPolicy
  def index?
    user.reporter?
  end
end
