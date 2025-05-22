When('il y a une demande d\'habilitation "France Connect" validée avec une habilitation FranceConnectée') do
  organization = create(:organization)

  @authorization_request = france_connect_authorization_request = create(
    :authorization_request,
    :france_connect,
    :validated,
    organization:,
  )
  france_connect_authorization = france_connect_authorization_request.authorizations.first

  create(
    :authorization_request,
    :api_droits_cnam,
    :validated,
    france_connect_authorization:,
    organization:,
  )
end
