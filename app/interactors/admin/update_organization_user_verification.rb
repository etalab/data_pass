class Admin::UpdateOrganizationUserVerification < ApplicationInteractor
  def call
    organizations_user.update!(
      verified: true,
      verified_reason: context.reason
    )
  end

  private

  def organizations_user
    context.organizations_user
  end
end
