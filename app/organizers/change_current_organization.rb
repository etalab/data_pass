class ChangeCurrentOrganization < ApplicationOrganizer
  organize FindOrCreateOrganization,
    UpdateOrganizationINSEEPayload,
    ChangeUserCurrentOrganization,
    AddUserToOrganization

  after do
    context.user.save!
  end
end
