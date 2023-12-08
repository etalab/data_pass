class ChangeCurrentOrganization < ApplicationOrganizer
  organize FindOrCreateOrganization,
    ChangeUserCurrentOrganization,
    AddUserToOrganization

  after do
    context.user.save!
  end
end
