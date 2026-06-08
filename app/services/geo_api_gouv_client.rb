class GeoAPIGouvClient
  BASE_URL = 'https://geo.api.gouv.fr'.freeze

  def get(path, params = {})
    response = connection.get(path, params)
    JSON.parse(response.body) if response.success?
  rescue Faraday::Error, JSON::ParserError
    nil
  end

  private

  def connection
    @connection ||= Faraday.new(url: BASE_URL) do |conn|
      conn.options.timeout = 5
    end
  end
end
