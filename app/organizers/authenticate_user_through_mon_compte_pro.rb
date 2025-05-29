class AuthenticateUserThroughMonComptePro < ApplicationOrganizer
  organize FindOrCreateOrganizationThroughMonComptePro,
    UpdateOrganizationINSEEPayload,
    FindOrCreateUserThroughMonComptePro,
    ChangeUserCurrentOrganization,
    AddUserToOrganization

  after do
    context.organization.save!
    context.user.save!
  end
end
