module AuthorizationCore::Contacts
  extend ActiveSupport::Concern

  included do
    unless respond_to?(:contacts)
      def self.contact_types
        @contact_types ||= []
      end

      def self.contact_attributes
        %w[
          family_name
          given_name
          email
          phone_number
          job_title
        ]
      end

      def self.contact(kind, validation_condition: nil)
        validation_condition ||= :need_complete_validation?

        class_eval do
          contact_attributes.each do |attr|
            store_accessor :data, "#{kind}_#{attr}"
            validates "#{kind}_#{attr}", presence: true, if: validation_condition
          end

          validates "#{kind}_email", format: { with: URI::MailTo::EMAIL_REGEXP }, if: validation_condition

          contact_types << kind
        end
      end

    end
  end
end
