class JeCliqueOuPasAPIClient
  def analyze(file)
    response = Faraday.new.post(analyze_url, file, headers)

    parsed_response = JSON.parse(response.body)

    {
      uuid: parsed_response['uuid'],
      error: parsed_response['error']
    }
  end

  private

  def headers
    { 'X-Auth-token': token }
  end

  def analyze_url
    "#{host}/submit"
  end

  def host
    Rails.application.credentials.je_clique_ou_pas[:host]
  end

  def token
    Rails.application.credentials.je_clique_ou_pas[:token]
  end
end
