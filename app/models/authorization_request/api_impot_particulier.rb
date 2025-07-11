class AuthorizationRequest::APIImpotParticulier < AuthorizationRequest
  include AuthorizationExtensions::BasicInfos
  include AuthorizationExtensions::PersonalData
  include AuthorizationExtensions::CadreJuridique
  include AuthorizationExtensions::GDPRContacts
  include AuthorizationExtensions::OperationalAcceptance
  include AuthorizationExtensions::SafetyCertification
  include AuthorizationExtensions::Volumetrie
  include DGFIPExtensions::APIImpotParticulierScopes
  include DGFIPExtensions::APIImpotParticulierModalities
  include DGFIPExtensions::ExtraContactsInfos

  VOLUMETRIES = {
    '50 appels / minute': 50,
    '100 appels / minute': 100,
    '200 appels / minute': 200,
    '500 appels / minute': 500,
    '750 appels / minute': 750,
    '1000 appels / minute': 1000,
  }.freeze

  add_documents :maquette_projet, content_type: ['application/pdf'], size: { less_than: 10.megabytes }

  add_attributes :date_prevue_mise_en_production,
    :volumetrie_approximative

  add_scopes

  contact :contact_technique, validation_condition: ->(record) { record.need_complete_validation?(:contacts) }

  add_checkbox :dpd_homologation_checkbox
end
