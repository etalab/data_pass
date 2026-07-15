class AuthorizationRequest::APIParticulierDemarcheNumerique < AuthorizationRequest
  include AuthorizationExtensions::BasicInfos
  include AuthorizationExtensions::PersonalData
  include AuthorizationExtensions::CadreJuridique
  include AuthorizationExtensions::Modalities

  MODALITIES = %w[params].freeze

  add_attributes :volumetrie_approximative

  add_scopes(validation: {
    presence: true, if: -> { need_complete_validation?(:scopes) }
  })

  %i[
    contact_metier
    delegue_protection_donnees
  ].each do |contact_kind|
    contact contact_kind, validation_condition: ->(record) { record.need_complete_validation?(:contacts) }
  end

  after_initialize :set_default_modalities

  def set_default_modalities
    return if modalities.present?

    data['modalities'] = MODALITIES
  end

  def mandatory_modalities?
    true
  end
end
