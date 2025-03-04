module AuthorizationCore::Documents
  extend ActiveSupport::Concern

  class DocumentType
    attr_reader :name

    def initialize(name:, multiple:)
      @name = name
      @multiple = multiple
    end

    def permitted_attribute
      if @multiple
        { name.to_sym => [] }
      else
        name.to_sym
      end
    end
  end

  included do
    unless respond_to?(:documents)
      def self.documents
        @documents ||= []
      end

      def self.add_document(name, validation_options = {})
        class_eval do
          has_one_attached name
          validates name, validation_options unless ENV['SKIP_DOCUMENT_VALIDATION']

          documents << DocumentType.new(name:, multiple: false)
        end
      end

      def self.add_multiple_documents(name, validation_options = {})
        class_eval do
          has_many_attached name
          validates name, validation_options unless ENV['SKIP_DOCUMENT_VALIDATION']

          documents << DocumentType.new(name:, multiple: true)
        end
      end
    end
  end
end
