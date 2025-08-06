class OrganizationPolicy < ApplicationPolicy
  def new?
    latest_identity_provider.can_link_to_organizations?
  end

  def create?
    latest_identity_provider.can_link_to_organizations? &&
      user.organizations.exclude?(record)
  end

  def latest_identity_provider
    IdentityProvider.find(authentication_session&.fetch('identity_provider_uid', nil))
  end
end
