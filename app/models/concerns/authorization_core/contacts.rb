module AuthorizationCore::Contacts
  extend ActiveSupport::Concern

  include AuthorizationCore::Attributes

  included do
    unless respond_to?(:contacts)
      def self.contacts
        @contacts ||= []
      end

      def self.contact_types
        contacts.map(&:type)
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

      def self.contact(kind, validation_condition:, options: {})
        class_eval do
          define_contact_type_methods(kind)
          define_common_contact_attributes(kind, validation_condition:)
          define_contact_person_attributes(kind, validation_condition:)

          contacts << ContactDefinition.new(kind, options)
        end
      end

      private

      def self.define_contact_type_methods(kind)
        validates "#{kind}_type", inclusion: { in: %w[person organization] }

        store_accessor :data, "#{kind}_type"

        define_method(:"#{kind}_type") do
          data["#{kind}_type"] || 'person'
        end
      end

      def self.define_common_contact_attributes(kind, validation_condition:)
        %w[email phone_number].each do |attr|
          store_accessor :data, "#{kind}_#{attr}"
          override_primitive_write("#{kind}_#{attr}")

          validates "#{kind}_#{attr}", presence: true, if: validation_condition
        end

        validates "#{kind}_email", format: { with: URI::MailTo::EMAIL_REGEXP }, if: validation_condition
        validates "#{kind}_email", email_recently_verified: true, if: validation_condition, on: :submit
      end

      def self.define_contact_person_attributes(kind, validation_condition:)
        %w[family_name given_name job_title].each do |attr|
          store_accessor :data, "#{kind}_#{attr}"
          override_primitive_write("#{kind}_#{attr}")

          validates "#{kind}_#{attr}", presence: true, if: -> { send(:"#{kind}_type") == 'person' && validation_condition.call(self) }
        end
      end
    end
  end

  def contacts
    @contacts ||= contact_types.map { |type| Contact.new(type, self) }
  end

  def contact_definitions
    self.class.contacts
  end

  delegate :contact_types, to: :class
end
