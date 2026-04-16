class LinkInEmailsInterceptor
  def self.delivering_email(message)
    linkify_html_part(message)
  end

  def self.previewing_email(message)
    linkify_html_part(message)
  end

  private_class_method def self.linkify_html_part(message)
    return unless message.html_part

    message.html_part.body = ApplicationController.helpers.auto_link(
      message.html_part.decoded,
      link: :urls,
      html: { target: '_blank', rel: 'noopener noreferrer' },
      sanitize: false
    )
    message.html_part.content_type = 'text/html; charset=UTF-8'
  end
end
