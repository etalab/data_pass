module AuthorizationExtensions::GDPRContacts
  extend ActiveSupport::Concern

  included do
    %i[
      responsable_traitement
      delegue_protection_donnees
    ].each do |contact_kind|
      contact contact_kind, validation_condition: -> { need_complete_validation?(:contacts) }
    end
  end
end
