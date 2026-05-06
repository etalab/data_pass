class Instruction::MergeManagedRoles < ApplicationInteractor
  def call
    context.user.roles = (preserved_roles + incoming_managed_roles).uniq
  end

  private

  def preserved_roles
    context.user.roles.reject { |role| manager_can_modify?(role) }
  end

  def incoming_managed_roles
    context.new_roles.select { |role| context.manager.manages_role?(role) }
  end

  def manager_can_modify?(role)
    context.manager.manages_role?(role) &&
      Instruction::ManagerScopeOptions::ALLOWED_ROLE_TYPES.include?(ParsedRole.parse(role).role)
  end
end
