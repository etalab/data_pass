class Admin::StopImpersonation < ApplicationOrganizer
  before do
    context.admin_event_name = 'stop_impersonation'
    context.admin_entity_key = :impersonation
    context.admin_before_attributes = {}
  end

  organize Admin::FinishImpersonationRecord,
    Admin::TrackEvent
end
