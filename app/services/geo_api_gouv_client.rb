class GeoAPIGouvClient
  class ServerError < StandardError; end

  BASE_URL = 'https://geo.api.gouv.fr'.freeze
  CACHE_TTL = 24.hours

  def commune(code)
    Rails.cache.fetch("geo:commune:#{code}", expires_in: CACHE_TTL) do
      body = get("/communes/#{code}", fields: 'nom,codeDepartement,codeRegion')
      next if body.nil?

      {
        code: body['code'],
        nom: body['nom'],
        code_departement: body['codeDepartement'],
        code_region: body['codeRegion']
      }
    end
  end

  private

  def get(path, params = {})
    connection.get(path, params).body
  rescue Faraday::ResourceNotFound
    nil
  rescue Faraday::ServerError => e
    raise ServerError, "geo.api.gouv.fr #{path} failed: #{e.message}", e.backtrace
  end

  def connection
    @connection ||= Faraday.new(url: BASE_URL) do |conn|
      conn.request :retry, max: 5
      conn.response :json, content_type: /\bjson$/
      conn.response :raise_error
      conn.options.timeout = 30
    end
  end
end
