class AddUserToOrganization < ApplicationInteractor
  def call
    context.user.add_to_organization(
      context.organization,
      identity_provider_uid: context.identity_provider_uid,
      identity_federator: context.identity_federator
    )
  end
end
