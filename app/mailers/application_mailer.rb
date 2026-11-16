class ApplicationMailer < ActionMailer::Base
  default from: "DataPass <#{Rails.application.config.default_from}>"

  layout 'mailer'

  before_action :build_host_from_env
  after_action :add_html_part_from_text

  def add_html_part_from_text
    return unless @_mail_was_called
    return if message.html_part

    text = text_body

    message.body = nil
    message.content_type = nil
    message.text_part = mail_part('text/plain', text)
    message.html_part = mail_part('text/html', html_from_text(text))
  end

  def text_body
    (message.text_part || message).body.decoded
  end

  def mail_part(mime_type, body)
    Mail::Part.new(content_type: "#{mime_type}; charset=UTF-8", body:)
  end

  def html_from_text(text)
    escaped = ERB::Util.html_escape(text).gsub(/\p{Extended_Pictographic}\u{FE0F}?/) { |emoji| %(<span aria-hidden="true">#{emoji}</span>) }
    paragraphs = view_context.simple_format(escaped, {}, sanitize: false)

    render_to_string(html: paragraphs, layout: 'mailer')
  end

  def default_url_options
    {
      host: @host
    }
  end

  def build_host_from_env
    @host = case Rails.env
            when 'production'
              'https://datapass.api.gouv.fr'
            when 'test', 'development'
              'http://localhost:3000'
            else
              "https://#{Rails.env}.datapass.api.gouv.fr"
            end
  end
end
