class AuthorizationRequest::Resana < AuthorizationRequest
  include AuthorizationExtensions::CadreJuridique

  %i[
    delegue_protection_donnees
    contact_metier
  ].each do |contact_kind|
    contact contact_kind, validation_condition: ->(record) { record.need_complete_validation?(:contacts) }
  end
end
