# frozen_string_literal: true

class INSEESireneAPIClient < AbstractINSEEAPIClient
  class EntityNotFoundError < StandardError; end

  ETABLISSEMENT_URL = 'https://api.insee.fr/api-sirene/prive/3.11/siret'

  def etablissement(siret:)
    ensure_insee_available!

    JSON.parse(etablissement_response_body(siret))
  rescue Faraday::ResourceNotFound => e
    raise EntityNotFoundError, "Etablissement with SIRET #{siret} not found: #{e.message}"
  rescue Faraday::UnauthorizedError => e
    INSEEAPIAuthentication.invalidate_access_token!
    pause_insee_calls!(e, 'INSEE rejected a freshly renewed access token')
  rescue JSON::ParserError => e
    raise InvalidResponseError, e.message
  end

  protected

  def etablissement_response_body(siret)
    http_connection.get("#{ETABLISSEMENT_URL}/#{siret}").body
  rescue Faraday::UnauthorizedError
    INSEEAPIAuthentication.invalidate_access_token!

    http_connection.get("#{ETABLISSEMENT_URL}/#{siret}").body
  end

  def http_connection
    super do |conn|
      conn.request :authorization, 'Bearer', -> { INSEEAPIAuthentication.access_token }
    end
  end
end
