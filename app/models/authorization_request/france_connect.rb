class AuthorizationRequest::FranceConnect < AuthorizationRequest
  include AuthorizationExtensions::BasicInfos
  include AuthorizationExtensions::PersonalData
  include AuthorizationExtensions::CadreJuridique
  include AuthorizationExtensions::GDPRContacts
  include AuthorizationExtensions::FranceConnectEidas

  add_documents :maquette_projet, content_type: ['application/pdf'], size: { less_than: 10.megabytes }

  add_attributes :date_prevue_mise_en_production,
    :volumetrie_approximative

  add_scopes(validation: {
    presence: true, if: -> { need_complete_validation?(:scopes) }
  })

  add_checkbox :alternative_connexion

  contact :contact_technique, validation_condition: ->(record) { record.need_complete_validation?(:contacts) }

  def france_connected_authorizations(ids = authorization_ids)
    Authorization.where(
      "data -> 'france_connect_authorization_id' in (?)",
      ids.map(&:to_s).uniq
    )
  end
end
