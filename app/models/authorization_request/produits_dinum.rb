class AuthorizationRequest::ProduitsDinum < AuthorizationRequest
  include AuthorizationExtensions::CadreJuridiqueDinum

  %i[
    contact_technique
    delegue_protection_donnees
    responsable_traitement
  ].each do |contact_kind|
    contact contact_kind,
      validation_condition: ->(record) { record.need_complete_validation?(:contacts) },
      options: { except: %w[phone_number job_title] }
  end
end
