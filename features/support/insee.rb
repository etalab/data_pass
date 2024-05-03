Before do |_scenario|
  stub_request(:post, 'https://api.insee.fr/token').to_return(
    status: 200,
    body: {
      access_token: 'token',
    }.to_json,
  )

  stub_request(:get, %r{^https://api.insee.fr/entreprises/sirene/V3.11/siret/}).to_return(
    status: 200,
    headers: { 'Content-Type' => 'application/json' },
    body: Rails.root.join('spec/fixtures/insee/13002526500013.json').read
  )
end
