class StartImpersonation < ApplicationOrganizer
  organize Admin::FindUserForImpersonation,
    Admin::CreateImpersonation
end
