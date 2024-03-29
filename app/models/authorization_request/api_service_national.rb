class AuthorizationRequest::APIServiceNational < AuthorizationRequest
  include AuthorizationExtensions::BasicInfos
  include AuthorizationExtensions::PersonalData
  include AuthorizationExtensions::CadreJuridique
  include AuthorizationExtensions::GDPRContacts

  contact :contact_technique, validation_condition: ->(record) { record.need_complete_validation?(:contacts) }
end
