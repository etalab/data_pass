class AddUserToOrganization < ApplicationInteractor
  def call
    context.user.add_to_organization(
      context.organization,
      identity_provider_uid: context.identity_provider_uid,
      identity_federator: context.identity_federator,
      verified: organization_link_verified,
      current:,
    )
  end

  protected

  def current
    false
  end

  private

  def organization_link_verified
    organization_link_already_verified? ||
      context.organization_link_verified ||
      false
  end

  def organization_link_already_verified?
    context.user.organizations_users.where(
      organization_id: context.organization.id,
      verified: true,
    ).any?
  end
end
