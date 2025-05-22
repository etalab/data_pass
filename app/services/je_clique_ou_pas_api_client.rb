class JeCliqueOuPasAPIClient
  def analyze(attachment)
    @blob = attachment.blob

    response = request_analyze_with_file
    parsed_response = JSON.parse(response.body)

    {
      uuid: parsed_response['uuid'],
      error: parsed_response['error']
    }
  end

  def result(uuid)
    response = request_results(uuid:)
    parsed_response = JSON.parse(response.body)

    {
      is_malware: parsed_response['is_malware'],
      analyzed_at: parsed_response['timestamp'],
      error: parsed_response['error']
    }
  end

  private

  def request_analyze_with_file
    with_temp_file do |file|
      faraday_client(multipart: true).post(
        analyze_url,
        file_payload(file:),
        headers(file:)
      )
    end
  end

  def request_results(uuid:)
    faraday_client.get(results_url(uuid), nil, headers)
  end

  def with_temp_file
    temp_file = create_temp_file
    yield temp_file
  ensure
    temp_file.close
    temp_file.unlink
  end

  def create_temp_file
    Tempfile.new(temp_file_params).tap do |file|
      file.binmode
      file.write(@blob.download)
      file.rewind
    end
  end

  def temp_file_params
    [@blob.filename.base, @blob.filename.extension_with_delimiter]
  end

  def file_payload(file:)
    { file: Faraday::Multipart::FilePart.new(file, @blob.content_type) }
  end

  def faraday_client(multipart: false)
    Faraday.new(ssl: { cert_store: }) do |faraday|
      if multipart
        faraday.request :multipart
        faraday.request :url_encoded
        faraday.adapter Faraday.default_adapter
      end
    end
  end

  def headers(file: nil)
    base_headers = { 'X-Auth-token': token }

    return base_headers unless file

    base_headers.merge(
      'Content-Type': 'multipart/form-data',
      'Content-Length': File.size(file).to_s,
      'Transfer-Encoding': 'chunked'
    )
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
    OpenSSL::X509::Store.new.tap do |store|
      store.set_default_paths
      store.add_cert(certificate)
    end
  end

  def certificate
    OpenSSL::X509::Certificate.new(Rails.application.credentials.je_clique_ou_pas[:certificate])
  end
end
