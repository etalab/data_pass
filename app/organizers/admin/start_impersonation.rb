class Admin::StartImpersonation < ApplicationOrganizer
  before do
    context.admin_event_name = 'start_impersonation'
    context.admin_entity_key = :impersonation
    context.admin_before_attributes = {}
  end

  organize Admin::FindUserForImpersonation,
    Admin::CreateImpersonation,
    Admin::TrackEvent
end
