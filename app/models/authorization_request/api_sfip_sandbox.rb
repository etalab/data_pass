class AuthorizationRequest::APISFiPSandbox < AuthorizationRequest
  include AuthorizationExtensions::BasicInfos
  include AuthorizationExtensions::PersonalData
  include AuthorizationExtensions::CadreJuridique
  include AuthorizationExtensions::GDPRContacts
  include DGFIPExtensions::APIImpotParticulierScopes
  include DGFIPExtensions::ExtraContactsInfos

  add_documents :maquette_projet, content_type: ['application/pdf'], size: { less_than: 10.megabytes }

  add_attributes :date_prevue_mise_en_production,
    :volumetrie_approximative

  add_scopes(validation: {
    presence: true, if: -> { need_complete_validation?(:scopes) }
  })

  contact :contact_technique, validation_condition: ->(record) { record.need_complete_validation?(:contacts) }

  add_checkbox :dpd_homologation_checkbox
end
