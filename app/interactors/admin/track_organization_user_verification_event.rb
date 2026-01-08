class Admin::TrackOrganizationUserVerificationEvent < ApplicationInteractor
  def call
    AdminEvent.create!(
      name: 'user_organization_verified',
      admin: context.admin,
      before_attributes:,
      after_attributes:,
      entity: context.organizations_user.user
    )
  end

  private

  def before_attributes
    {
      organization_id: context.organizations_user.organization_id,
      verified: context.verified_before,
      verified_reason: context.verified_reason_before
    }
  end

  def after_attributes
    {
      organization_id: context.organizations_user.organization_id,
      verified: context.organizations_user.verified,
      verified_reason: context.organizations_user.verified_reason
    }
  end
end
