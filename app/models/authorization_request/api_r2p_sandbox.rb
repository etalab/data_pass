class AuthorizationRequest::APIR2PSandbox < AuthorizationRequest
  include AuthorizationExtensions::BasicInfos
  include AuthorizationExtensions::PersonalData
  include AuthorizationExtensions::CadreJuridique
  include AuthorizationExtensions::GDPRContacts
  include AuthorizationExtensions::Modalities
  include DGFIPExtensions::ExtraContactsInfos

  MODALITIES = %w[with_acces_etat_civil with_acces_spi with_acces_etat_civil_et_adresse with_acces_etat_civil_restitution_spi with_acces_etat_civil_complet_adresse with_acces_etat_civil_degrade_adresse].freeze

  add_documents :maquette_projet, content_type: ['application/pdf'], size: { less_than: 10.megabytes }

  add_attributes :date_prevue_mise_en_production,
    :volumetrie_approximative

  contact :contact_technique, validation_condition: ->(record) { record.need_complete_validation?(:contacts) }

  add_checkbox :dpd_homologation_checkbox
end
