class AuthorizationRequest::HubEEDila < AuthorizationRequest
  add_scopes(validation: {
    presence: true, if: -> { need_complete_validation?(:scopes) }
  })

  contact :administrateur_metier, validation_condition: ->(record) { record.need_complete_validation?(:contacts) }
end
