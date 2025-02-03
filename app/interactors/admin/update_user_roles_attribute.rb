class Admin::UpdateUserRolesAttribute < ApplicationInteractor
  def call
    user.roles = context.roles
    user.roles.uniq!
    user.save
  end

  private

  def user
    context.user
  end
end
