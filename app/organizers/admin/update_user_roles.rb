class Admin::UpdateUserRoles < ApplicationOrganizer
  before do
    context.admin_entity_key = :user
    context.admin_event_name = 'user_roles_changed'
    context.admin_before_attributes = {
      roles: context.user.roles,
    }
  end

  organize Admin::UpdateUserRolesAttribute,
    Admin::TrackEvent,
    Admin::NotifyAdminsForRolesUpdate

  after do
    context.user.save
  end
end
