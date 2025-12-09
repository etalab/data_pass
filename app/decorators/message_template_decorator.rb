class MessageTemplateDecorator < ApplicationDecorator
  delegate_all

  def preview_content
    authorization_request = object.authorization_definition.authorization_request_class.new(id: 9001)
    interpolator = MessageTemplateInterpolator.new(object.content)
    interpolator.interpolate(authorization_request)
  rescue ArgumentError
    object.content
  end

  def preview_mail(entity_name:)
    header = h.render(partial: 'mailer/shared/applicant/header', locals: { entity_name: })
    footer = h.render(partial: 'mailer/shared/applicant/footer', locals: { authorization_definition_name: object.authorization_definition.name })

    h.simple_format("#{header}\n\n#{mailer_description}\n\n#{footer}")
  end

  def mailer_description
    t(
      "authorization_request_mailer.#{template_type_key}.description",
      authorization_request_id: 9001,
      authorization_request_name: 'Exemple de demande',
      authorization_request_url: h.authorization_request_url(id: 9001),
      reason_var_key => preview_content,
    )
  end

  private

  def template_type_key
    case object.template_type.to_sym
    when :refusal
      'refuse'
    when :modification_request
      'request_changes'
    else
      raise "Unknown message template type: #{object.message_template_type}"
    end
  end

  def reason_var_key
    case object.template_type.to_sym
    when :refusal
      :authorization_request_denial_reason
    when :modification_request
      :authorization_request_modification_request_reason
    else
      raise "Unknown message template type: #{object.message_template_type}"
    end
  end
end
