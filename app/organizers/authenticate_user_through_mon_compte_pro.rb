class AuthenticateUserThroughMonComptePro < ApplicationOrganizer
  organize FindOrCreateOrganizationThroughMonComptePro,
    UpdateOrganizationINSEEPayload,
    FindOrCreateUserThroughMonComptePro,
    AddUserToOrganization,
    ChangeUserCurrentOrganization

  after do
    context.organization.save!
    context.user.save!
  end
end
