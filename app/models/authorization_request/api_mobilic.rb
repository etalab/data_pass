class AuthorizationRequest::APIMobilic < AuthorizationRequest
  include AuthorizationExtensions::BasicInfos
  include AuthorizationExtensions::PersonalData
  include AuthorizationExtensions::GDPRContacts

  add_attributes :date_prevue_mise_en_production

  contact :contact_technique, validation_condition: ->(record) { record.need_complete_validation?(:contacts) }
end
