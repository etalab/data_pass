class ChangeUserCurrentOrganization < ApplicationInteractor
  def call
    context.user.add_to_organization(context.organization, current: true)
  end
end
