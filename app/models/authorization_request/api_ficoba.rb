class AuthorizationRequest::APIFicoba < AuthorizationRequest
  include AuthorizationExtensions::BasicInfos
  include AuthorizationExtensions::PersonalData
  include AuthorizationExtensions::CadreJuridique
  include AuthorizationExtensions::GDPRContacts
  include AuthorizationExtensions::OperationalAcceptance
  include AuthorizationExtensions::SafetyCertification
  include AuthorizationExtensions::Volumetrie
  include AuthorizationExtensions::Modalities

  MODALITIES = %w[with_ficoba_iban with_ficoba_spi with_ficoba_siren with_ficoba_personne_physique with_ficoba_personne_morale].freeze

  VOLUMETRIES = {
    '50 appels / minute': 50,
    '200 appels / minute': 200,
    '1000 appels / minute': 1000,
  }.freeze

  add_document :maquette_projet, content_type: ['application/pdf'], size: { less_than: 10.megabytes }

  add_attributes :date_prevue_mise_en_production,
    :volumetrie_approximative

  add_scopes(validation: {
    presence: true, if: -> { need_complete_validation?(:scopes) }
  })

  contact :contact_technique, validation_condition: ->(record) { record.need_complete_validation?(:contacts) }

  add_checkbox :dpd_homologation_checkbox
end
