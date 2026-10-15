GEO_API_NAVIGATEUR_REPONSES = {
  %r{\Ahttps://geo\.api\.gouv\.fr/communes/92023\?} => { nom: 'Clamart' },
  %r{\Ahttps://geo\.api\.gouv\.fr/departements/69\?} => { nom: 'Rhône' },
  %r{\Ahttps://geo\.api\.gouv\.fr/departements/69/communes\?} => [
    { nom: 'Lyon' },
    { nom: 'Villeurbanne' }
  ]
}.freeze

Before('@geo_api_navigateur') do
  browser = page.driver.browser
  browser.network.intercept

  browser.on(:request) do |request|
    reponse = GEO_API_NAVIGATEUR_REPONSES.find { |motif, _| request.match?(motif) }&.last

    if reponse
      corps = reponse.to_json
      request.respond(
        body: corps,
        responseHeaders: {
          'content-type' => 'application/json',
          'content-length' => corps.bytesize,
          'access-control-allow-origin' => '*'
        }
      )
    else
      request.continue
    end
  end
end
