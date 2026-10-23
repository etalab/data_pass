class Admin::RevokeAPIAccess < ApplicationOrganizer
  around do |organizer|
    ActiveRecord::Base.transaction { organizer.call }
  end

  organize Admin::RevokeAPIAccessGrant,
    Admin::SyncAPIAccessScopes
end
