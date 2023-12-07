class AuthenticateUser < ApplicationOrganizer
  organize FindOrCreateUser,
    FindOrCreateOrganization,
    AddUserToOrganization
end
