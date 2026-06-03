class Instruction::AuthorizationDefinitionPolicy < ApplicationPolicy
  def show?
    user.reporter?(record.id)
  end

  class Scope < Scope
    def resolve
      return scope.all if user.admin?

      scope.all.select { |definition| user.reporter?(definition.id) }
    end
  end
end
