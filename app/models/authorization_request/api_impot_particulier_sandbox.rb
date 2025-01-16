class AuthorizationRequest::APIImpotParticulierSandbox < AuthorizationRequest
  include AuthorizationExtensions::BasicInfos
  include AuthorizationExtensions::PersonalData
  include AuthorizationExtensions::CadreJuridique
  include AuthorizationExtensions::GDPRContacts
  include DGFIPExtensions::APIImpotParticulierScopes
  include DGFIPExtensions::APIImpotParticulierModalities

  add_document :maquette_projet, content_type: ['application/pdf'], size: { less_than: 10.megabytes }

  add_attributes :date_prevue_mise_en_production
  add_attribute :extra_organization_contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }
  add_attribute :contact_technique_extra_email, format: { with: URI::MailTo::EMAIL_REGEXP }
  add_attribute :extra_organization_contact_name

  add_scopes(validation: {
    presence: true, if: -> { need_complete_validation?(:scopes) }
  })

  contact :contact_technique, validation_condition: ->(record) { record.need_complete_validation?(:contacts) }

  add_checkbox :dpd_homologation_checkbox
end
