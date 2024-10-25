class JeCliqueOuPasAPIClient
  def analyze(file_content)
    @file_content = file_content

    response = Faraday.new(ssl: { cert_store: }).post(analyze_url, body, headers)

    parsed_response = JSON.parse(response.body)

    {
      uuid: parsed_response['uuid'],
      error: parsed_response['error']
    }
  end

  def result(uuid)
    response = Faraday.new.get(results_url(uuid), nil, headers)

    parsed_response = JSON.parse(response.body)

    {
      is_malware: parsed_response['is_malware'],
      analyzed_at: parsed_response['timestamp'],
      error: parsed_response['error']
    }
  end

  private

  def headers
    {
      'X-Auth-token': token
    }
  end

  def body
    { file: @file_content }
  end

  def analyze_url
    "#{host}/submit"
  end

  def results_url(uuid)
    "#{host}/results/#{uuid}"
  end

  def host
    Rails.application.credentials.je_clique_ou_pas[:host]
  end

  def token
    Rails.application.credentials.je_clique_ou_pas[:token]
  end

  def cert_store
    OpenSSL::X509::Store.new.tap { |store| store.add_cert(certificate) }
  end

  def certificate
    OpenSSL::X509::Certificate.new(Rails.application.credentials.je_clique_ou_pas[:certificate])
  end
end
