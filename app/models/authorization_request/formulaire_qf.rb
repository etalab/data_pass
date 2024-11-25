class AuthorizationRequest::FormulaireQF < AuthorizationRequest
  include AuthorizationExtensions::CadreJuridique
  include AuthorizationExtensions::PersonalData

  %i[
    contact_metier
    delegue_protection_donnees
  ].each do |contact_kind|
    contact contact_kind, validation_condition: ->(record) { record.need_complete_validation?(:contacts) }
  end
end
