class BulkAuthorizationRequestUpdateNotificationRead < ApplicationRecord
  belongs_to :bulk_authorization_request_update
  belongs_to :user

  validates :bulk_authorization_request_update_id, uniqueness: { scope: :user_id }
end
