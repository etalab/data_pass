class INSEESireneAPIClient < AbstractINSEEAPIClient
  def etablissement(siret:)
    http_connection.get(
      "https://api.insee.fr/api-sirene/prive/3.11/siret/#{siret}",
    ).body
  end

  protected

  def http_connection
    super do |conn|
      conn.request :authorization, 'Bearer', -> { INSEEAPIAuthentication.new.access_token }
    end
  end
end
