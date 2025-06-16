class ChangeCurrentOrganizationThroughMonComptePro < ApplicationOrganizer
  organize FindOrCreateOrganizationThroughMonComptePro,
    UpdateOrganizationINSEEPayload,
    ChangeUserCurrentOrganization,
    AddUserToOrganization

  before do
    context.identity_provider_uid = User::IDENTITY_PROVIDERS.key('mon_compte_pro')
    context.identity_federator = 'mon_compte_pro'
  end

  after do
    context.user.save!
  end
end
