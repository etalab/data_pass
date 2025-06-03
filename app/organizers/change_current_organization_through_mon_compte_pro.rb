class ChangeCurrentOrganizationThroughMonComptePro < ApplicationOrganizer
  organize FindOrCreateOrganizationThroughMonComptePro,
    UpdateOrganizationINSEEPayload,
    ChangeUserCurrentOrganization,
    AddUserToOrganization

  after do
    context.user.save!
  end
end
