class AuthenticateUser < ApplicationOrganizer
  organize FindOrCreateOrganization,
    FindOrCreateUser,
    ChangeUserCurrentOrganization,
    AddUserToOrganization

  after do
    context.organization.save!
    context.user.save!
  end
end
