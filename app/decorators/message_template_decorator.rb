class MessageTemplateDecorator < ApplicationDecorator
  delegate_all

  def preview_mail(entity_name:)
    h.simple_format(h.linkify_urls(rendered_preview(entity_name)), {}, sanitize: false)
  end

  private

  def rendered_preview(entity_name)
    MessageTemplatePreviewRenderer.new(object, entity_name:).render
  rescue StandardError => e
    Sentry.capture_exception(e)
    object.content
  end
end
