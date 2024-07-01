module AuthorizationCore::Attributes
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

      def self.add_attribute(name, options = {})
        class_eval do
          store_accessor :data, name

          validates name, options[:validation] if options[:validation].present?

          overwrite_array_accessor(name) if options[:type] == :array

          extra_attributes.push(name)
        end
      end

      private

      def self.overwrite_array_accessor(name)
        define_method(name) do
          data[name.to_s] ||= []

          begin
            JSON.parse(data[name.to_s]).sort
          rescue StandardError
            data[name.to_s].sort
          end
        end

        define_method(:"#{name}=") do |value|
          value = (value || []).compact_blank

          super(value.sort)
        end
      end
    end
  end
end
