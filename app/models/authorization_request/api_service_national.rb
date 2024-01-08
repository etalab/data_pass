class AuthorizationRequest::APIServiceNational < AuthorizationRequest
  include AuthorizationExtensions::BasicInfos
  include AuthorizationExtensions::PersonalData
  include AuthorizationExtensions::CadreJuridique
  include AuthorizationExtensions::GDPRContacts

  add_document :maquette_projet, content_type: ['application/pdf'], size: { less_than: 10.megabytes }

  add_attributes :date_prevue_mise_en_production,
    :volumetrie_approximative

  %i[
    contact_technique
  ].each do |contact_kind|
    contact contact_kind, validation_condition: -> { need_complete_validation?(:contacts) }
  end
end
