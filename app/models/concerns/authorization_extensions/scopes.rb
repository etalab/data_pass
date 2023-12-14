module AuthorizationExtensions::Scopes
  extend ActiveSupport::Concern

  included do
    unless respond_to?(:scopes_enabled?)
      def self.scopes_enabled?
        @scopes_enabled
      end

      def self.add_scopes
        class_eval do
          store_accessor :data, :scopes

          @scopes_enabled = true
        end
      end
    end
  end
end
