class AuthorizationRequest::APIENSUDocuments < AuthorizationRequest
  include AuthorizationExtensions::BasicInfos
  include AuthorizationExtensions::PersonalData
  include AuthorizationExtensions::CadreJuridique
  include AuthorizationExtensions::GDPRContacts
  include AuthorizationExtensions::OperationalAcceptance
  include AuthorizationExtensions::SafetyCertification
  include AuthorizationExtensions::Volumetrie
  include DGFIPExtensions::ExtraContactsInfos

  VOLUMETRIES = {
    '500 appels / minute': 500,
  }.freeze

  add_documents :maquette_projet, content_type: ['application/pdf'], size: { less_than: 10.megabytes }

  add_attributes :date_prevue_mise_en_production

  contact :contact_technique, validation_condition: ->(record) { record.need_complete_validation?(:contacts) }

  add_checkbox :dpd_homologation_checkbox
end
