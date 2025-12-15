class EnsureUserIsOrganizationMember < ApplicationInteractor
  def call
    return unless user && organization
    return if user.organizations.include?(organization)

    user.add_to_organization(
      organization,
      verified: false,
      identity_federator: 'unknown',
      identity_provider_uid: nil
    )
    user.reload
  end

  def rollback
    user.organizations_users.find_by(organization: organization)&.destroy
  end

  delegate :user, to: :context
  delegate :organization, to: :context
end
