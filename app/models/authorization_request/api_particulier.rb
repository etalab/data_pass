class AuthorizationRequest::APIParticulier < AuthorizationRequest
  include AuthorizationExtensions::BasicInfos
  include AuthorizationExtensions::PersonalData
  include AuthorizationExtensions::CadreJuridique

  add_document :maquette_projet, content_type: ['application/pdf'], size: { less_than: 10.megabytes }

  add_attributes :date_prevue_mise_en_production,
    :volumetrie_approximative

  add_attribute :modalities,
    type: :array,
    validation: {
      presence: true,
      intersection: { in: %w[params formulaire_qf] },
    }

  add_scopes(validation: {
    presence: true, if: -> { need_complete_validation?(:scopes) }
  })

  contact :contact_technique, validation_condition: ->(record) { record.need_complete_validation?(:contacts) }
  contact :delegue_protection_donnees, validation_condition: ->(record) { record.need_complete_validation?(:contacts) }

  after_initialize :set_default_modalities

  def set_default_modalities
    return if modalities.present?

    data['modalities'] = %w[params]
  end
end
