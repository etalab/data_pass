class AuthorizationRequest::AnnuaireDesEntreprise < AuthorizationRequest
  include AuthorizationExtensions::CadreJuridique

  add_attributes :intitule, :description
end
