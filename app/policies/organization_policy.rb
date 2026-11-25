class OrganizationPolicy < ApplicationPolicy
  def new?
    latest_identity_provider.can_link_to_organizations?
  end

  def create?
    latest_identity_provider.can_link_to_organizations? &&
      user.organizations.exclude?(record)
  end

  def start_dirigeant_verification?
    organization_missing? || !public_sector_organization?
  end

  def latest_identity_provider
    IdentityProvider.find(authentication_session&.fetch('identity_provider_uid', nil))
  end

  private

  def organization_missing?
    record.nil?
  end

  def public_sector_organization?
    PublicSectorClassification.new(record).public?
  end
end
