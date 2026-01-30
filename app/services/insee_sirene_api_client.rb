class INSEESireneAPIClient < AbstractINSEEAPIClient
  class EntityNotFoundError < StandardError; end
  class InvalidResponseError < StandardError; end

  def etablissement(siret:)
    response = http_connection.get(
      "https://api.insee.fr/api-sirene/prive/3.11/siret/#{siret}",
    ).body

    JSON.parse(response)
  rescue Faraday::ResourceNotFound => e
    raise EntityNotFoundError, "Etablissement with SIRET #{siret} not found: #{e.message}"
  rescue JSON::ParserError => e
    raise InvalidResponseError, e.message
  end

  private

  def http_connection
    @http_connection ||= Faraday.new do |conn|
      conn.request :retry, max: 5
      conn.request :authorization, 'Bearer', -> { INSEEAPIAuthentication.new.access_token }
      conn.response :raise_error
      conn.options.timeout = 2
    end
  end
end
