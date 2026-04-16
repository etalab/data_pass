class Admin::BanUser < ApplicationOrganizer
  before do
    context.admin_event_name = 'user_banned'
    context.admin_entity_key = :target_user
  end

  organize Admin::FindUserByEmail,
    Admin::CaptureUserBanAttributes,
    Admin::MarkUserAsBanned,
    Admin::TrackEvent
end
