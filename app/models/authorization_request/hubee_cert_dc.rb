class AuthorizationRequest::HubEECertDC < AuthorizationRequest
  validates :organization, uniqueness: { conditions: -> { where.not(state: 'archived') } }

  contact :administrateur_metier, validation_condition: ->(record) { record.need_complete_validation? }
end
