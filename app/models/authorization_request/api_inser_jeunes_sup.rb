class AuthorizationRequest::APIInserJeunesSup < AuthorizationRequest
  include AuthorizationExtensions::BasicInfos
  include AuthorizationExtensions::CadreJuridique
  include AuthorizationExtensions::GDPRContacts

  add_documents :maquette_projet, content_type: ['application/pdf'], size: { less_than: 10.megabytes }

  add_attributes :date_prevue_mise_en_production,
    :volumetrie_approximative7

  contact :contact_technique, validation_condition: ->(record) { record.need_complete_validation?(:contacts) }
end
