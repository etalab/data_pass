class AuthorizationRequest::AnnuaireDesEntreprises < AuthorizationRequest
  include AuthorizationExtensions::BasicInfos
  include AuthorizationExtensions::CadreJuridique

  add_scopes(validation: {
    presence: true, if: -> { need_complete_validation?(:scopes) }
  })
end
