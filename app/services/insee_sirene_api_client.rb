# frozen_string_literal: true

class INSEESireneAPIClient < AbstractINSEEAPIClient
  class EntityNotFoundError < StandardError; end

  ETABLISSEMENT_URL = 'https://api.insee.fr/api-sirene/prive/3.11/siret'

  def etablissement(siret:)
    ensure_insee_available!

    response = http_connection.get("#{ETABLISSEMENT_URL}/#{siret}").body

    JSON.parse(response)
  rescue Faraday::ResourceNotFound => e
    raise EntityNotFoundError, "Etablissement with SIRET #{siret} not found: #{e.message}"
  rescue Faraday::UnauthorizedError => e
    INSEEAPIAuthentication.invalidate_access_token!
    pause_insee_calls!(e, 'INSEE rejected our access token')
  rescue JSON::ParserError => e
    raise InvalidResponseError, e.message
  end

  protected

  def http_connection
    super do |conn|
      conn.request :authorization, 'Bearer', -> { INSEEAPIAuthentication.access_token }
    end
  end
end
