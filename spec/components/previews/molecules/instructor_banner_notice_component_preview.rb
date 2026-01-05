class Molecules::InstructorBannerNoticeComponentPreview < ViewComponent::Preview
  def changes_requested
    authorization_request = AuthorizationRequest.changes_requested.first
    render Molecules::InstructorBannerNoticeComponent.new(authorization_request:)
  end

  def refused
    authorization_request = AuthorizationRequest.refused.first
    render Molecules::InstructorBannerNoticeComponent.new(authorization_request:)
  end
end
