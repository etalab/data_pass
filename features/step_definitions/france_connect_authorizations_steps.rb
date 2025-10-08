When('il y a une demande d\'habilitation "FranceConnect" validée avec une habilitation FranceConnectée') do
  organization = create(:organization)

  @authorization_request = france_connect_authorization_request = create(
    :authorization_request,
    :france_connect,
    :validated,
    organization:,
  )
  france_connect_authorization = france_connect_authorization_request.authorizations.first

  france_connected_request = create(
    :authorization_request,
    :api_impot_particulier_sandbox,
    :validated,
    organization:,
  )
  france_connected_authorization = france_connected_request.authorizations.first

  france_connected_authorization.data['france_connect_authorization_id'] = france_connect_authorization.id
  france_connected_authorization.data['modalities'] = %w[]
  france_connected_authorization.save!
end
