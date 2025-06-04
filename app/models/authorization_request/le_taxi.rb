class AuthorizationRequest::LeTaxi < AuthorizationRequest
  include AuthorizationExtensions::BasicInfos
  include AuthorizationExtensions::PersonalData
  include AuthorizationExtensions::GDPRContacts
  include AuthorizationExtensions::TechnicalTeam

  TECHNICAL_TEAM_TYPES = {
    'Mon éditeur de logiciel' => 'editor',
    'Mon équipe de développeurs' => 'internal',
    'Autre' => 'other'
  }.freeze

  TECHNICAL_TEAM_TYPES_REQUIRING_VALUES = %w[editor other].freeze

  add_documents :maquette_projet, content_type: ['application/pdf'], size: { less_than: 10.megabytes }

  add_attributes :date_prevue_mise_en_production,
    :volumetrie_approximative

  contact :contact_technique, validation_condition: ->(record) { record.need_complete_validation?(:contacts) }
end
