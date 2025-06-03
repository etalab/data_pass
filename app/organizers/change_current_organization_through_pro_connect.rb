class ChangeCurrentOrganizationThroughProConnect < ApplicationOrganizer
  organize FindOrCreateOrganizationThroughProConnect,
    UpdateOrganizationINSEEPayload,
    ChangeUserCurrentOrganization,
    AddUserToOrganization

  before do
    # Extract the dynamic idp_id from ProConnect payload
    context.identity_provider_uid = context.pro_connect_omniauth_payload.dig('extra', 'raw_info', 'idp_id')
  end

  after do
    context.user.save!
  end
end
