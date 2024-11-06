module AuthorizationExtensions::GDPRContacts
  extend ActiveSupport::Concern

  NAMES = %i[
    responsable_traitement
    delegue_protection_donnees
  ].freeze

  included do
    unless respond_to?(:contacts_step)
      def contacts_step
        :contacts
      end
    end

    NAMES.each do |contact_kind|
      contact contact_kind, validation_condition: ->(record) { record.need_complete_validation?(record.contacts_step) }
    end
  end
end
