class Instruction::UpdateUserRights < ApplicationOrganizer
  before do
    context.admin = context.manager
    context.admin_entity_key = :user
    context.admin_event_name = 'user_rights_changed_by_manager'
    context.admin_before_attributes = { roles: context.user.roles.dup }
  end

  organize Instruction::MergeManagedRoles,
    Admin::TrackEvent,
    Admin::NotifyAdminsForRolesUpdate

  after { context.user.save }
end
