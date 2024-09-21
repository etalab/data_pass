class BulkAuthorizationRequestUpdateNotificationExtractor
  attr_reader :authorization_request, :user

  def initialize(authorization_request, user)
    @authorization_request = authorization_request
    @user = user
  end

  def perform
    return unless authorization_request.applicant == user
    return unless authorization_request.bulk_updates.any?
    return if read_nodification_exists?

    create_read_notification

    authorization_request.latest_bulk_update
  end

  private

  def create_read_notification
    BulkAuthorizationRequestUpdateNotificationRead.create!(
      bulk_authorization_request_update: authorization_request.latest_bulk_update,
      user:,
    )
  end

  def read_nodification_exists?
    BulkAuthorizationRequestUpdateNotificationRead.exists?(
      bulk_authorization_request_update_id: authorization_request.latest_bulk_update.id,
      user_id: user.id,
    )
  end
end
