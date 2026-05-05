class Instruction::MergeManagedRoles < ApplicationInteractor
  def call
    context.user.roles = (preserved_roles + incoming_managed_roles).uniq
  end

  private

  def preserved_roles
    context.user.roles.reject { |role| authority_can_modify?(role) }
  end

  def incoming_managed_roles
    context.new_roles.select { |role| context.authority.user.manages_role?(role) }
  end

  def authority_can_modify?(role)
    context.authority.user.manages_role?(role) &&
      context.authority.allowed_role_types.include?(ParsedRole.parse(role).role)
  end
end
