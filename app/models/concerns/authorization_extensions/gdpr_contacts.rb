module AuthorizationExtensions::GDPRContacts
  extend ActiveSupport::Concern

  NAMES = %i[
    responsable_traitement
    delegue_protection_donnees
  ].freeze

  included do
    NAMES.each do |contact_kind|
      contact contact_kind, validation_condition: -> { need_complete_validation?(:contacts) }
    end
  end
end
