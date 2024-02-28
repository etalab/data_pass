module AuthorizationExtensions::GDPRContacts
  extend ActiveSupport::Concern

  GDPR_CONTACTS = %i[
    responsable_traitement
    delegue_protection_donnees
  ].freeze

  included do
    GDPR_CONTACTS.each do |contact_kind|
      contact contact_kind, validation_condition: -> { need_complete_validation?(:contacts) }
    end
  end
end
