class Admin::StartImpersonation < ApplicationOrganizer
  organize Admin::FindUserForImpersonation,
    Admin::CreateImpersonation,
    Admin::StartImpersonationSession,
    Admin::TrackImpersonationStart
end
