class Admin::StopImpersonation < ApplicationOrganizer
  organize Admin::FinishImpersonationRecord,
    Admin::StopImpersonationSession,
    Admin::TrackImpersonationStop
end
