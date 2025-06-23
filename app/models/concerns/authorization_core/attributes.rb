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
          value = JSON.parse(value) if value.is_a?(String)
          raise(TypeError, "#{name} should be an array") unless value.is_a?(Array) || value.nil?

          value = (value || []).compact_blank.map(&:strip).uniq
          value.map! { |v| sanitize_html(v) }

          super(value.sort)
        end
      end

      def self.override_boolean_reader(name)
        define_method(name) do
          %w[1 on].include?(data[name.to_s])
        end
      end

      def self.override_primitive_write(name, sanitize_options: { strip: true, downcase: false })
        define_method(:"#{name}=") do |value|
          value = value.try(:strip) || value if sanitize_options[:strip]
          value = value.try(:downcase) || value if sanitize_options[:downcase]

          super(sanitize_html(value))
        end
      end

      private

      def sanitize_html(value)
        return if value.blank?

        CGI.unescapeHTML(Loofah.fragment(value.to_s).scrub!(:strip).to_text)
      end
    end
  end
end
