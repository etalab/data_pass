class AuthenticateUserThroughMonComptePro < ApplicationOrganizer
  organize FindOrCreateOrganizationThroughMonComptePro,
    UpdateOrganizationINSEEPayload,
    FindOrCreateUserThroughMonComptePro,
    AddUserToOrganization,
    ChangeUserCurrentOrganization

  before do
    context.identity_provider_uid = '71144ab3-ee1a-4401-b7b3-79b44f7daeeb'
    context.identity_federator = 'mon_compte_pro'
    context.organization_link_verified = true
  end

  after do
    context.organization.save!
    context.user.save!
  end
end
