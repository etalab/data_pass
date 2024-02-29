class ApplicationMailer < ActionMailer::Base
  default from: "DataPass <#{Rails.application.config.default_from}>"

  layout 'mailer'

  before_action :extract_host

  def extract_host
    ActionMailer::Base.default_url_options[:host] = current_host
  end

  def current_host
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
