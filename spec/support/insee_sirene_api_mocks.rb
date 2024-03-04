# frozen_string_literal: true

module INSEESireneAPIMocks
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
