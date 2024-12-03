class ApplicationMailer < ActionMailer::Base
  default from: "DataPass <#{Rails.application.config.default_from}>"

  layout 'mailer'

  before_action :extract_host

  # rubocop:disable Metrics/AbcSize
  def extract_host
    if params[:authorization_request].present?
      build_host_from_authorization_request(params[:authorization_request])
    elsif params[:message].present?
      build_host_from_authorization_request(params[:message].authorization_request)
    elsif params[:authorization_request_transfer].present?
      build_host_from_authorization_request(params[:authorization_request_transfer].authorization_request)
    end
  end
  # rubocop:enable Metrics/AbcSize

  def default_url_options
    {
      host: @host
    }
  end

  def build_host_from_authorization_request(authorization_request)
    subdomain = Subdomain.find_for_authorization_request(authorization_request)

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
    else
      "https://#{Rails.env}.v2.datapass.api.gouv.fr"
    end
  end
end
