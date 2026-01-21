class MessageTemplatePreviewRenderer
  TEMPLATE_TYPE_TO_MAILER_ACTION = {
    refusal: 'refuse',
    modification_request: 'request_changes',
    approval: 'approve'
  }.freeze

  PREVIEW_REQUEST_ID = 9001

  def initialize(message_template, entity_name:)
    @message_template = message_template
    @entity_name = entity_name
  end

  def render
    ApplicationController.render(
      template: template_path,
      assigns: { authorization_request: build_authorization_request },
      formats: [:text]
    )
  end

  private

  attr_reader :message_template, :entity_name

  def template_path
    kind_specific = "authorization_request_mailer/#{authorization_definition_uid}/#{mailer_action}"
    generic = "authorization_request_mailer/#{mailer_action}"

    template_exists?(kind_specific) ? kind_specific : generic
  end

  def template_exists?(path)
    ApplicationController.new.lookup_context.exists?(path, [], false)
  end

  def mailer_action
    TEMPLATE_TYPE_TO_MAILER_ACTION.fetch(message_template.template_type.to_sym)
  end

  def authorization_definition_uid
    message_template.authorization_definition_uid
  end

  def build_authorization_request
    authorization_request_class.new(id: PREVIEW_REQUEST_ID, intitule: 'Exemple de demande').tap do |request|
      request.applicant = preview_applicant
      request.build_denial(reason: interpolated_content)
      request.build_modification_request(reason: interpolated_content)

      authorization = Authorization.new(message: interpolated_content)
      request.define_singleton_method(:latest_authorization) { authorization }
    end
  end

  def preview_applicant
    User.new(family_name: entity_name.split.last, given_name: entity_name.split.first)
  end

  def authorization_request_class
    message_template.authorization_definition.authorization_request_class
  end

  def interpolated_content
    @interpolated_content ||= begin
      request = authorization_request_class.new(id: PREVIEW_REQUEST_ID)
      MessageTemplateInterpolator.new(message_template.content).interpolate(request)
    rescue ArgumentError
      message_template.content
    end
  end
end
