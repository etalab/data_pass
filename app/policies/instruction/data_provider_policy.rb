class Instruction::DataProviderPolicy < ApplicationPolicy
  # NOTE: iterates AuthorizationDefinition.all on every request — cheap while
  # definitions are static records (~30-50). Revisit once they live in DB
  # (DP-1719/1671 migration), where this becomes a hot-path N+1.
  def show?
    user.admin? ||
      AuthorizationDefinition.all
        .select { |ad| ad.provider_slug == record.slug }
        .any? { |ad| user.reporter?(ad.id) }
  end

  class Scope < Scope
    def resolve
      return scope.all if user.admin?

      accessible_slugs = AuthorizationDefinition.all
        .select { |ad| user.reporter?(ad.id) }
        .map(&:provider_slug)
        .uniq

      scope.where(slug: accessible_slugs)
    end
  end
end
