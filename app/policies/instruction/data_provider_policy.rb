class Instruction::DataProviderPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.all if user.admin?

      provider_slugs = user.roles.filter_map { |r|
        parsed_role = ParsedRole.parse(r)
        parsed_role.provider_slug if parsed_role.provider_slug && parsed_role.role.in?(User::ROLES)
      }.uniq

      scope.where(slug: provider_slugs)
    end
  end

  def index?
    user.reporter? || user.manager?
  end
end
