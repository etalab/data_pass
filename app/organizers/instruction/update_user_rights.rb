class Instruction::UpdateUserRights < ApplicationOrganizer
  before do
    context.admin = context.actor
    context.admin_entity_key = :user
    context.admin_event_name = context.authority.audit_event_name
    context.admin_before_attributes = { roles: context.user.roles.dup }
  end

  organize Instruction::MergeManagedRoles,
    Admin::TrackEvent,
    Admin::NotifyAdminsForRolesUpdate

  after { context.user.save }
end
