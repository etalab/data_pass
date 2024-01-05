class ApplicationMailer < ActionMailer::Base
  default from: 'DataPass <notifications@api.gouv.fr>'

  layout 'mailer'

  before_action :extract_host

  def extract_host
    default_url_options[:host] = current_host
  end

  def current_host
    case Rails.env
    when 'production'
      Rails.application.host
    else
      'http://localhost:3000'
    end
  end
end
