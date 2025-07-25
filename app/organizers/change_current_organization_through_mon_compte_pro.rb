class ChangeCurrentOrganizationThroughMonComptePro < ApplicationOrganizer
  organize FindOrCreateOrganizationThroughMonComptePro,
    UpdateOrganizationINSEEPayload,
    ChangeUserCurrentOrganization,
    AddUserToOrganization

  before do
    context.identity_provider_uid = '71144ab3-ee1a-4401-b7b3-79b44f7daeeb'
    context.identity_federator = 'mon_compte_pro'
  end

  after do
    context.user.save!
  end
end
