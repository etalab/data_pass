class Admin::UpdateUserRolesAttribute < ApplicationInteractor
  def call
    user.roles = valid_roles
    user.roles.uniq!
    user.save
  end

  private

  def valid_roles
    context.roles.select do |role|
      admin_role?(role) ||
        valid_role_for_authorization_request_type?(role)
    end
  end

  def admin_role?(role)
    role == 'admin'
  end

  def valid_role_for_authorization_request_type?(role)
    authorization_request_type, role_type = role.split(':')

    return false unless authorization_request_types.include?(authorization_request_type)
    return false unless User::ROLES.include?(role_type)

    true
  end

  def authorization_request_types
    AuthorizationDefinition.all.map(&:id)
  end

  def user
    context.user
  end
end
