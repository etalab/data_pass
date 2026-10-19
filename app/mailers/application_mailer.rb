class ApplicationMailer < ActionMailer::Base
  default from: "DataPass <#{Rails.application.config.default_from}>"

  layout 'mailer'

  before_action :extract_host
  after_action :add_html_part_from_text

  # rubocop:disable-next Metrics/AbcSize
  def extract_host
    if params[:authorization_request].present?
      build_host_from_authorization_definition(params[:authorization_request].definition)
    elsif params[:authorization].present?
      build_host_from_authorization_definition(params[:authorization].request.definition)
    elsif params[:message].present?
      build_host_from_authorization_definition(params[:message].authorization_request.definition)
    elsif params[:authorization_request_transfer].present?
      build_host_from_authorization_definition(params[:authorization_request_transfer].authorization_request.definition)
    elsif params[:instructor_draft_request].present?
      build_host_from_authorization_definition(params[:instructor_draft_request].request.definition)
    elsif params[:webhook].present?
      build_host_from_authorization_definition(params[:webhook].definition)
    end
  end

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

  def build_host_from_authorization_definition(definition)
    subdomain = Subdomain.find_for_authorization_definition(definition)

    @host = if subdomain
              build_host_from_env_and_subdomain(subdomain)
            else
              build_host_from_env
            end
  end

  def build_host_from_env_and_subdomain(subdomain)
    case Rails.env
    when 'production'
      "https://#{subdomain.id}.v2.datapass.api.gouv.fr"
    when 'test', 'development'
      'http://localhost:3000'
    else
      "https://#{Rails.env}.#{subdomain.id}.v2.datapass.api.gouv.fr"
    end
  end

  def build_host_from_env
    case Rails.env
    when 'production'
      'https://v2.datapass.api.gouv.fr'
    when 'test', 'development'
      'http://localhost:3000'
    else
      "https://#{Rails.env}.v2.datapass.api.gouv.fr"
    end
  end
end
