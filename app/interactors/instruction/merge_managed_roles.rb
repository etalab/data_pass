class Instruction::MergeManagedRoles < ApplicationInteractor
  def call
    context.user.roles = (preserved_roles + incoming_managed_roles).uniq
  end

  private

  def preserved_roles
    context.user.roles.reject { |role| context.authority.can_manage_role?(role) }
  end

  def incoming_managed_roles
    context.new_roles.select { |role| context.authority.can_manage_role?(role) }
  end
end
