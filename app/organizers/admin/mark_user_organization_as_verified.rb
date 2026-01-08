class Admin::MarkUserOrganizationAsVerified < ApplicationOrganizer
  before do
    context.verified_before = context.organizations_user.verified
    context.verified_reason_before = context.organizations_user.verified_reason
  end

  organize Admin::UpdateOrganizationUserVerification,
    Admin::TrackOrganizationUserVerificationEvent
end
