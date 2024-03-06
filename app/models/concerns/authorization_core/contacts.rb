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

      def self.contact(kind, validation_condition:)
        class_eval do
          store_accessor :data, "#{kind}_type"

          define_method(:"#{kind}_type") do
            data["#{kind}_type"] || 'person'
          end

          validates "#{kind}_type", inclusion: { in: %w[person organization] }

          %w[email phone_number].each do |attr|
            store_accessor :data, "#{kind}_#{attr}"
            validates "#{kind}_#{attr}", presence: true, if: validation_condition
          end

          %w[family_name given_name job_title].each do |attr|
            store_accessor :data, "#{kind}_#{attr}"
            validates "#{kind}_#{attr}", presence: true, if: -> { send(:"#{kind}_type") == 'person' && validation_condition.call(self) }
          end

          validates "#{kind}_email", format: { with: URI::MailTo::EMAIL_REGEXP }, if: validation_condition
          validates "#{kind}_email", email_recently_verified: true, if: validation_condition, on: :submit

          contact_types << kind
        end
      end
    end
  end

  def contact_types
    self.class.contact_types
  end
end
