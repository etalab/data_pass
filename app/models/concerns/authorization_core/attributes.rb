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

          if options[:type] == :array
            override_array_accessor(name)
          elsif options[:type] == :boolean
            override_boolean_reader(name)
          else
            override_primitive_write(name)
          end

          extra_attributes.push(name)
        end
      end

      private

      def self.override_array_accessor(name)
        override_array_reader(name)
        override_array_writer(name)
      end

      def self.override_array_reader(name)
        define_method(name) do
          data[name.to_s] ||= []

          begin
            JSON.parse(data[name.to_s]).sort
          rescue StandardError
            data[name.to_s].sort
          end
        end
      end

      def self.override_array_writer(name)
        define_method(:"#{name}=") do |value|
          raise(TypeError, "#{name} should be an array") unless value.is_a?(Array) || value.nil?

          value = (value || []).compact_blank.map(&:strip).uniq

          super(value.sort)
        end
      end

      def self.override_boolean_reader(name)
        define_method(name) do
          %w[1 on].include?(data[name.to_s])
        end
      end

      def self.override_primitive_write(name)
        define_method(:"#{name}=") do |value|
          super(value.try(:strip) || value)
        end
      end
    end
  end
end
