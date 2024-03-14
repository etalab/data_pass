class AuthorizationRequest::HubEECertDC < AuthorizationRequest
  validates :organization, uniqueness: true

  contact :administrateur_metier, validation_condition: ->(record) { record.need_complete_validation? }
end
