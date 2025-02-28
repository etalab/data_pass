Sachantque('le temps moyen de traitement est de {int} jours') do |days|
  stub_request(:get, 'https://metabase.entreprise.api.gouv.fr/public/question/4c5e0ed6-bbd9-498e-a61a-34f5ee39f84b.json')
    .to_return(
      status: 200,
      body: [{ average_days: days }].to_json,
    )
end
