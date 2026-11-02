Quand('le fournisseur de données pose par API la métadonnée {string} à {string}') do |key, value|
  authorization_request = AuthorizationRequest.last

  UpdateAuthorizationRequestFromAPI.call!(
    authorization_request:,
    authorization_request_form: authorization_request.form,
    authorization_request_params: ActionController::Parameters.new,
    api_metadata: { key => value },
    user: FactoryBot.create(:user, :developer, authorization_request_types: [authorization_request.definition.id])
  )
end
