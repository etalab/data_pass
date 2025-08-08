class AuthenticateUserThroughProConnect < ApplicationOrganizer
  organize FindOrCreateOrganizationThroughProConnect,
    UpdateOrganizationINSEEPayload,
    FindOrCreateUserThroughProConnect,
    AddUserToOrganization,
    ChangeUserCurrentOrganization

  before do
    context.identity_provider_uid = context.pro_connect_omniauth_payload.dig('extra', 'raw_info', 'idp_id')
    context.identity_federator = 'pro_connect'
    context.organization_link_verified = IdentityProvider.find(context.identity_provider_uid).siret_verified?
  end

  after do
    context.organization.save!
    context.user.save!
  end
end
