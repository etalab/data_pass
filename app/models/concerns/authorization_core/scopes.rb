module AuthorizationCore::Scopes
  extend ActiveSupport::Concern

  included do
    unless respond_to?(:scopes_enabled?)
      def self.scopes_enabled?
        @scopes_enabled
      end

      def self.add_scopes(options = {})
        class_eval do
          store_accessor :data, :scopes

          def scopes
            data['scopes'] ||= []
            begin
              JSON.parse(super)
            rescue StandardError
              super
            end
          end

          @scopes_enabled = true

          validates :scopes, options[:validation] if options[:validation].present?
        end
      end
    end
  end

  def available_scopes
    @available_scopes ||= definition.scopes
  end
end
