class AuthorizationRequest::AnnuaireDesEntreprise < AuthorizationRequest
  include AuthorizationExtensions::BasicInfos
  include AuthorizationExtensions::CadreJuridique

  add_attributes :description_equipe

  add_scopes(validation: {
    presence: true, if: -> { need_complete_validation?(:scopes) }
  })
end
