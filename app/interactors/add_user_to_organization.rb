class AddUserToOrganization < ApplicationInteractor
  def call
    context.organization.users << context.user unless context.organization.users.include?(context.user)
  end
end
