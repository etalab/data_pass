# frozen_string_literal: true

module INSEESireneAPIMocks
  def mock_insee_sirene_api_etablissement_valid(siret: nil, full: false)
    mock_insee_authentication

    stub_request(:get, %r{^https://api.insee.fr/api-sirene/prive/3.11/siret/}).to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: insee_sirene_api_etablissement_valid_payload(siret:, full:).to_json
    )
  end

  def mock_insee_sirene_api_etablissement_not_found
    mock_insee_authentication

    stub_request(:get, %r{^https://api.insee.fr/api-sirene/prive/3.11/siret/}).to_return(
      status: 404,
      headers: { 'Content-Type' => 'application/json' },
      body: insee_sirene_api_not_found_payload.to_json
    )
  end

  def mock_insee_authentication
    stub_request(:post, 'https://auth.insee.net/auth/realms/apim-gravitee/protocol/openid-connect/token').to_return(
      status: 200,
      body: {
        access_token: 'token',
      }.to_json,
    )
  end

  def insee_sirene_api_etablissement_valid_payload(siret: nil, full: false)
    if full
      read_json_fixture("insee/#{siret}.json")
    else
      {
        'header' => {
          'statut' => 200,
          'message' => 'OK',
        },
        'etablissement' => {
          'siren' => siret.first(9) || generate(:siret),
        }
      }
    end
  end

  def insee_sirene_api_not_found_payload
    {
      'header' => {
        'statut' => 404,
        'message' => 'Not Found',
      },
    }
  end
end
