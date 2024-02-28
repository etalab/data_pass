module AuthorizationExtensions::GDPRContacts
  extend ActiveSupport::Concern

  NAME = %i[
    responsable_traitement
    delegue_protection_donnees
  ].freeze

  included do
    NAME.each do |contact_kind|
      contact contact_kind, validation_condition: -> { need_complete_validation?(:contacts) }
    end
  end
end
