class AuthorizationRequest::AnnuaireDesEntreprises < AuthorizationRequest
  include AuthorizationExtensions::CadreJuridique

  add_attributes :intitule, :description
end
