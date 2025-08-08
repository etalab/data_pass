# rubocop:disable Metrics/BlockLength
Before do |scenario|
  stub_request(:post, 'https://auth.insee.net/auth/realms/apim-gravitee/protocol/openid-connect/token').to_return(
    status: 200,
    body: {
      access_token: 'token',
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
# rubocop:enable Metrics/BlockLength
