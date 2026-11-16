module DatapassHost
  def self.url(env = Rails.env)
    case env
    when 'production'
      'https://datapass.api.gouv.fr'
    when 'test', 'development'
      'http://localhost:3000'
    else
      "https://#{env}.datapass.api.gouv.fr"
    end
  end
end
