class MessageTemplateDecorator < ApplicationDecorator
  delegate_all

  def preview_mail(entity_name:)
    rendered = MessageTemplatePreviewRenderer.new(object, entity_name:).render
    html = h.simple_format(rendered).to_s
    Nokogiri::HTML(LinkifyUrlsInterceptor.linkify_html(html)).at('body').inner_html.html_safe
  end
end
