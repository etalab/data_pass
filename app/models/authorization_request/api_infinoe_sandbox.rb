class AuthorizationRequest::APIInfinoeSandbox < AuthorizationRequest
  include AuthorizationExtensions::BasicInfos
  include AuthorizationExtensions::CadreJuridique
  include AuthorizationExtensions::GDPRContacts

  add_document :maquette_projet, content_type: ['application/pdf'], size: { less_than: 10.megabytes }
  add_attributes :date_prevue_mise_en_production,
    :volumetrie_approximative

  contact :contact_technique, validation_condition: -> { need_complete_validation?(:contacts) }

  def production_authorization_request
    AuthorizationRequest::APIInfinoeProduction.where("data->'sandbox_authorization_request_id' = ?", id.to_s).first
  end
end
