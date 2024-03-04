class AuthenticateUser < ApplicationOrganizer
  organize FindOrCreateOrganization,
    UpdateOrganizationINSEEPayload,
    FindOrCreateUser,
    ChangeUserCurrentOrganization,
    AddUserToOrganization

  after do
    context.organization.save!
    context.user.save!
  end
end
