class Admin::UpdateUserRolesAttribute < ApplicationInteractor
  def call
    user.roles = valid_roles
    user.roles.uniq!
    user.save
  end

  private

  def valid_roles
    context.roles.select { |role| ParsedRole.valid?(role) }
  end

  def user
    context.user
  end
end
