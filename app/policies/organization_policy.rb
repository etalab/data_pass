class OrganizationPolicy < ApplicationPolicy
  def new?
    user.current_identity_provider.can_link_to_organizations?
  end

  def create?
    user.current_identity_provider.can_link_to_organizations? &&
      user.organizations.exclude?(record)
  end
end
