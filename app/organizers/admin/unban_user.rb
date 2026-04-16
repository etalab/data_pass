class Admin::UnbanUser < ApplicationOrganizer
  before do
    context.admin_event_name = 'user_unbanned'
    context.admin_entity_key = :target_user
  end

  organize Admin::CaptureUserBanAttributes,
    Admin::MarkUserAsUnbanned,
    Admin::TrackEvent
end
