class AuthorizationRequest::APIDeclarationAutoEntrepreneur < AuthorizationRequest
  include AuthorizationExtensions::BasicInfos
  include AuthorizationExtensions::PersonalData
  include AuthorizationExtensions::CadreJuridique
  include AuthorizationExtensions::GDPRContacts

  add_documents :maquette_projet, content_type: ['application/pdf'], size: { less_than: 10.megabytes }
  add_documents :attestation_fiscale, content_type: ['application/pdf'], size: { less_than: 10.megabytes }
  validates :attestation_fiscale, presence: true, if: -> { need_complete_validation?(:supporting_documents) }

  add_scopes

  contact :contact_technique, validation_condition: ->(record) { record.need_complete_validation?(:contacts) }
end
