class AuthorizationRequest::APICaptchEtat < AuthorizationRequest
  include AuthorizationExtensions::BasicInfos

  add_documents :maquette_projet, content_type: ['application/pdf'], size: { less_than: 10.megabytes }

  add_attributes :date_prevue_mise_en_production,
    :volumetrie_approximative

  validates :volumetrie_approximative, presence: true, if: -> { need_complete_validation?(:basic_infos) }

  contact :contact_technique, validation_condition: ->(record) { record.need_complete_validation?(:contacts) }
end
