class AuthorizationRequest::APIMobilic < AuthorizationRequest
  include AuthorizationExtensions::BasicInfos
  include AuthorizationExtensions::PersonalData
  include AuthorizationExtensions::GDPRContacts

  add_attributes :date_prevue_mise_en_production

  validates :date_prevue_mise_en_production, presence: true, if: -> { need_complete_validation?(:basic_infos) }

  contact :contact_technique, validation_condition: ->(record) { record.need_complete_validation?(:contacts) }

  %i[
    contact_technique
    responsable_traitement
    delegue_protection_donnees
  ].each do |contact_kind|
    validates "#{contact_kind}_phone_number", french_phone_number: true, if: ->(record) { record.need_complete_validation?(:contacts) }
  end
end
