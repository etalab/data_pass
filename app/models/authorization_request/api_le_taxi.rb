class AuthorizationRequest::APILeTaxi < AuthorizationRequest
  include AuthorizationExtensions::BasicInfos
  include AuthorizationExtensions::PersonalData
  include AuthorizationExtensions::GDPRContacts

  add_document :maquette_projet, content_type: ['application/pdf'], size: { less_than: 10.megabytes }

  add_attributes :date_prevue_mise_en_production,
    :volumetrie_approximative

  add_document :cadre_juridique_document, content_type: ['application/pdf'], size: { less_than: 10.megabytes }
  add_attribute :cadre_juridique_url

  validate :cadre_juridique_document_or_cadre_juridique_url_present, if: -> { need_complete_validation?(:legal_api_le_taxi) }

  add_attribute :cadre_juridique_nature
  validates :cadre_juridique_nature, presence: true, if: -> { need_complete_validation?(:legal_api_le_taxi) }

  contact :contact_technique, validation_condition: -> { need_complete_validation?(:contacts) }

  def cadre_juridique_document_or_cadre_juridique_url_present
    return if cadre_juridique_document.present? || cadre_juridique_url.present?

    errors.add(:cadre_juridique_document, :blank)
    errors.add(:cadre_juridique_url, :blank)
  end
end
