class ChangeUserCurrentOrganization < ApplicationInteractor
  def call
    context.user.current_organization = context.organization
  end
end
