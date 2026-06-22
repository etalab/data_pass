class Instruction::DataProviderPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.all if user.admin?

      scope.where(slug: user.roles_for(:reporter).provider_slugs)
    end
  end

  def index?
    user.reporter? || user.manager?
  end
end
