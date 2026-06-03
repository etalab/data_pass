class Instruction::AuthorizationRequestFormPolicy < ApplicationPolicy
  def show?
    user.reporter?(record.authorization_definition.id)
  end
end
