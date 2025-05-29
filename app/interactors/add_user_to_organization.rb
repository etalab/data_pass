class AddUserToOrganization < ApplicationInteractor
  def call
    context.user.add_to_organization(context.organization)
  end
end
