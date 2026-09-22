# rubocop:disable-next Metrics/BlockLength
Before do |scenario|
  INSEEAPIAuthentication.invalidate_access_token!

  stub_request(:post, INSEEAPIAuthentication::TOKEN_URL).to_return(
    status: 200,
    headers: { 'Content-Type' => 'application/json' },
    body: {
      access_token: 'token',
      expires_in: 3600,
    }.to_json,
  )

  if scenario.source_tag_names.include?('@SiretInexistant')
    stub_request(:get, %r{^https://api.insee.fr/api-sirene/prive/3.11/siret/}).to_return(
      status: 404,
      headers: { 'Content-Type' => 'application/json' }
    )
  else
    stub_request(:get, %r{^https://api.insee.fr/api-sirene/prive/3.11/siret/}).to_return do |request|
      siret = request.uri.path.split('/').last

      payload = if Rails.root.join('spec/fixtures/insee', "#{siret}.json").exist?
                  Rails.root.join('spec/fixtures/insee', "#{siret}.json").read
                else
                  Rails.root.join('spec/fixtures/insee/13002526500013.json').read
                end

      {
        status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: payload,
      }
    end
  end
end
