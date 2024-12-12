class AuthorizationRequest::APIOpale < AuthorizationRequest
  include AuthorizationExtensions::BasicInfos
  include AuthorizationExtensions::PersonalData
  include AuthorizationExtensions::CadreJuridique
  include AuthorizationExtensions::GDPRContacts
  include AuthorizationExtensions::OperationalAcceptance
  include AuthorizationExtensions::SafetyCertification
  include AuthorizationExtensions::Volumetrie

  VOLUMETRIES = {
    '500 appels / minute': 500,
  }.freeze

  add_document :maquette_projet, content_type: ['application/pdf'], size: { less_than: 10.megabytes }

  add_attributes :date_prevue_mise_en_production

  contact :contact_technique, validation_condition: ->(record) { record.need_complete_validation?(:contacts) }
end
