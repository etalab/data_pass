module Instruction
  module MessageTemplatesLoader
    extend ActiveSupport::Concern

    included do
      before_action :load_message_templates_for_authorization_request, only: %i[new create] # rubocop:disable Rails/LexicallyScopedActionFilter
      before_action :load_email_preview, only: %i[new create] # rubocop:disable Rails/LexicallyScopedActionFilter
    end

    private

    def load_message_templates_for_authorization_request
      @message_templates = load_message_templates
    end

    def load_email_preview
      @email_preview = EmailPreviewRenderer.new(@authorization_request, action: email_preview_action).render
    end

    def email_preview_action
      return :request_changes if message_template_type == :modification_request

      message_template_type
    end

    def load_message_templates
      authorization_definition_uid = @authorization_request.definition.id

      MessageTemplate
        .for_authorization_definition(authorization_definition_uid)
        .for_type(message_template_type)
        .order(:title)
    end

    def message_template_type
      raise NotImplementedError, 'Subclass must implement message_template_type method'
    end
  end
end
