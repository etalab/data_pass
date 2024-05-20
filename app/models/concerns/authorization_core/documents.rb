module AuthorizationCore::Documents
  extend ActiveSupport::Concern

  included do
    unless respond_to?(:documents)
      def self.documents
        @documents ||= []
      end

      def self.add_document(name, validation_options = {})
        class_eval do
          has_one_attached name
          validates name, validation_options unless ENV['SKIP_DOCUMENT_VALIDATION']

          documents << name
        end
      end
    end
  end
end
