require 'rails_helper'

RSpec.describe BulkAuthorizationRequestUpdateNotificationRead, type: :model do
  it 'has a valid factory' do
    expect(build(:bulk_authorization_request_update_notification_read)).to be_valid
  end
end
