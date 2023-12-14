module AuthorizationExtensions::Attributes
  extend ActiveSupport::Concern

  included do
    unless respond_to?(:extra_attributes)
      def self.extra_attributes
        @extra_attributes ||= []
      end

      def self.add_attributes(*names)
        names.each do |name|
          add_attribute(name)
        end
      end

      def self.add_attribute(name)
        class_eval do
          store_accessor :data, name

          extra_attributes.push(name)
        end
      end
    end
  end
end
