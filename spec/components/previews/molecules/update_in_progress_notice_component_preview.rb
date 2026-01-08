class Molecules::UpdateInProgressNoticeComponentPreview < ViewComponent::Preview
  def default
    authorization = Authorization.joins(:request).where(authorization_requests: { state: 'draft' }).first
    render Molecules::UpdateInProgressNoticeComponent.new(authorization:)
  end
end
