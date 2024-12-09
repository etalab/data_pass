class AuthorizationRequest::APIParticulier < AuthorizationRequest
  include AuthorizationExtensions::BasicInfos
  include AuthorizationExtensions::PersonalData
  include AuthorizationExtensions::CadreJuridique
  include AuthorizationExtensions::Modalities

  MODALITIES = %w[params formulaire_qf].freeze

  add_document :maquette_projet, content_type: ['application/pdf'], size: { less_than: 10.megabytes }

  add_attributes :date_prevue_mise_en_production,
    :volumetrie_approximative

  add_scopes(validation: {
    presence: true, if: -> { need_complete_validation?(:scopes) }
  })

  %i[
    contact_metier
    contact_technique
    delegue_protection_donnees
  ].each do |contact_kind|
    contact contact_kind, validation_condition: ->(record) { record.need_complete_validation?(:contacts) }
  end

  after_initialize :set_default_modalities

  def set_default_modalities
    return if modalities.present?

    data['modalities'] = %w[params]
  end

  def mandatory_modalities?
    true
  end
end
