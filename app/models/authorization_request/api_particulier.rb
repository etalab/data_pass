class AuthorizationRequest::APIParticulier < AuthorizationRequest
  include AuthorizationExtensions::BasicInfos
  include AuthorizationExtensions::PersonalData
  include AuthorizationExtensions::CadreJuridique
  include AuthorizationExtensions::Modalities
  include AuthorizationExtensions::FranceConnect
  include AuthorizationExtensions::FranceConnectEmbeddedFields

  MODALITIES = %w[params formulaire_qf france_connect].freeze

  add_documents :maquette_projet, content_type: ['application/pdf'], size: { less_than: 10.megabytes }

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

  validate :contact_technique_phone_number_must_be_mobile_if_france_connect,
    if: ->(record) { record.need_complete_validation?(:contacts) }

  after_initialize :set_default_modalities

  def set_default_modalities
    return if modalities.present?

    data['modalities'] = %w[params]
  end

  def with_france_connect?
    modalities.include?('france_connect') &&
      france_connect_authorization_id.present?
  end

  def mandatory_modalities?
    true
  end

  def skip_france_connect_authorization?
    form.service_provider&.france_connect_certified? &&
      Rails.application.credentials.dig(:feature_flags, :apipfc) == true
  end

  def requires_france_connect_authorization?
    return false if skip_france_connect_authorization?

    return false unless need_complete_validation?(:modalities)
    return false unless modalities.include?('france_connect')

    !embeds_france_connect_fields?
  end

  def embeds_france_connect_fields?
    return false unless france_connect_modality?

    [
      fc_cadre_juridique_nature,
      fc_cadre_juridique_url,
      fc_scopes
    ].any?(&:present?)
  end

  private

  def contact_technique_phone_number_must_be_mobile_if_france_connect
    return unless france_connect_modality?
    return if contact_technique_phone_number.blank?

    validator = FrenchPhoneNumberValidator.new(attributes: [:contact_technique_phone_number], mobile: true)
    validator.validate_each(self, :contact_technique_phone_number, contact_technique_phone_number)
  end
end
