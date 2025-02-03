class AuthorizationRequest::APIDroitsCNAM < AuthorizationRequest
  include AuthorizationExtensions::BasicInfos
  include AuthorizationExtensions::PersonalData
  include AuthorizationExtensions::CadreJuridique
  include AuthorizationExtensions::GDPRContacts

  add_attribute :france_connect_authorization_id

  validates :france_connect_authorization_id,
    presence: true,
    inclusion: { in: ->(authorization_request) { authorization_request.organization.valid_authorizations_of(AuthorizationRequest::FranceConnect).pluck(:id).map(&:to_s) } },
    if: -> { need_complete_validation?(:france_connect) }

  add_document :maquette_projet, content_type: ['application/pdf'], size: { less_than: 10.megabytes }

  add_attributes :date_prevue_mise_en_production,
    :volumetrie_approximative

  contact :contact_technique, validation_condition: ->(record) { record.need_complete_validation?(:contacts) }

  def france_connect_authorization
    return nil if france_connect_authorization_id.blank?

    Authorization.find(france_connect_authorization_id)
  end
end
