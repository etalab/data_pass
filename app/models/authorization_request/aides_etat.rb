class AuthorizationRequest::AidesEtat < AuthorizationRequest
  contact :contact_metier, validation_condition: ->(record) { record.need_complete_validation?(:contacts) }
end
