class ChangeCurrentOrganizationThroughProConnect < ApplicationOrganizer
  organize FindOrCreateOrganizationThroughProConnect,
    UpdateOrganizationINSEEPayload,
    ChangeUserCurrentOrganization,
    AddUserToOrganization

  before do
    context.identity_provider_uid = context.pro_connect_omniauth_payload.dig('extra', 'raw_info', 'idp_id')
    context.identity_federator = 'pro_connect'
  end

  after do
    context.user.save!
  end
end
