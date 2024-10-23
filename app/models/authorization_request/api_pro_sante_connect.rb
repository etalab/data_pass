class AuthorizationRequest::APIProSanteConnect < AuthorizationRequest
  include AuthorizationExtensions::BasicInfos
  include AuthorizationExtensions::CadreJuridique
  include AuthorizationExtensions::GDPRContacts

  add_scopes(validation: {
    presence: true, if: -> { need_complete_validation?(:scopes) }
  })

  contact :contact_technique, validation_condition: ->(record) { record.need_complete_validation?(:contacts) }
end
