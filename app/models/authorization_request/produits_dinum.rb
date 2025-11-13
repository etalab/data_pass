class AuthorizationRequest::ProduitsDinum < AuthorizationRequest
  include AuthorizationExtensions::CadreJuridique

  add_scopes(validation: {
    presence: true, if: -> { need_complete_validation?(:scopes) }
  })

  %i[
    contact_metier
    contact_technique
    delegue_protection_donnees
    responsable_administration
  ].each do |contact_kind|
    contact contact_kind, validation_condition: ->(record) { record.need_complete_validation?(:contacts) }
  end
end
