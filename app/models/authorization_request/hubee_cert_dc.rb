class AuthorizationRequest::HubEECertDC < AuthorizationRequest
  validates :organization, uniqueness: true
  contact :administrateur_metier
end
