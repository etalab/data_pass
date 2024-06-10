class AuthorizationRequest::APIParticulier < AuthorizationRequest
  include AuthorizationExtensions::BasicInfos
  include AuthorizationExtensions::PersonalData
  include AuthorizationExtensions::CadreJuridique
  include AuthorizationExtensions::GDPRContacts
  include AuthorizationExtensions::Modalities

  add_document :maquette_projet, content_type: ['application/pdf'], size: { less_than: 10.megabytes }

  add_attributes :date_prevue_mise_en_production,
    :volumetrie_approximative

  add_scopes(validation: {
    presence: true, if: -> { need_complete_validation?(:scopes) }
  })

  add_modalities(validation: {
    presence: true, if: -> { need_complete_validation?(:modalities) }
  })

  contact :contact_technique, validation_condition: ->(record) { record.need_complete_validation?(:contacts) }
end
