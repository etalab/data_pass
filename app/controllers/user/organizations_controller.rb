class User::OrganizationsController < AuthenticatedUserController
  def index
    @organizations_users = current_user.organizations_users.includes(:organization)
  end
end
