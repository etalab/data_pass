class MessageTemplateDecorator < ApplicationDecorator
  delegate_all

  def preview_content
    authorization_request = object.authorization_definition.authorization_request_class.new(id: 9001)
    interpolator = MessageTemplateInterpolator.new(object.content)
    interpolator.interpolate(authorization_request)
  rescue ArgumentError
    object.content
  end

  def preview_with_header_footer(entity_name:)
    header = h.render(partial: 'mailer/shared/applicant/header', locals: { entity_name: })
    footer = h.render(partial: 'mailer/shared/applicant/footer', locals: { authorization_definition_name: object.authorization_definition.name })

    h.simple_format("#{header}\n\n#{preview_content}\n\n#{footer}")
  end
end
