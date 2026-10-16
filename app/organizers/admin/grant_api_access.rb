class Admin::GrantAPIAccess < ApplicationOrganizer
  around do |organizer|
    ActiveRecord::Base.transaction { organizer.call }
  end

  organize Admin::CreateAPIAccessGrant,
    Admin::SyncAPIAccessScopes
end
