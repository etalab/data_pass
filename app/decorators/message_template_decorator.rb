class MessageTemplateDecorator < ApplicationDecorator
  delegate_all

  def preview_mail(entity_name:)
    rendered = MessageTemplatePreviewRenderer.new(object, entity_name:).render

    h.simple_format(rendered)
  end
end
