module SubdomainsHelper
  delegate :host, to: :request

  def app_subdomain
    case Rails.env
    when 'development', 'test'
      host.split('.').first
    when 'sandbox'
      host.split('.')[1]
    when 'production'
      top_level, second_level = host.split('.')[0..1]

      if top_level.start_with?('production')
        second_level
      else
        top_level
      end
    end
  end
end
