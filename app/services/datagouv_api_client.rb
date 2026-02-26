class DatagouvAPIClient
  class ServerError < StandardError; end

  def upload_resource(file_path)
    connection.post(upload_path) do |req|
      req.body = { file: Faraday::FilePart.new(file_path, 'text/csv', File.basename(file_path)) }
    end
  rescue Faraday::ServerError => e
    body = e.response&.body
    message = "data.gouv.fr upload returned #{e.response&.status}: #{body.presence || e.message}"
    raise ServerError, message, e.backtrace
  end

  def update_resource_title(title)
    connection.put(resource_path) do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = { title: title }.to_json
    end
  end

  def update_dataset_temporal_coverage(start_date:)
    payload = fetch_dataset.merge(
      'temporal_coverage' => {
        'start' => start_date.to_s,
        'end' => nil
      }
    )
    connection.put(dataset_path) do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = payload.to_json.dup.force_encoding(Encoding::UTF_8)
    end
  end

  private

  def connection
    @connection ||= Faraday.new(url: base_url) do |conn|
      conn.request :multipart
      conn.request :json
      conn.response :json, content_type: /\bjson$/
      conn.response :raise_error
      conn.adapter Faraday.default_adapter
      conn.headers['X-API-KEY'] = api_key
    end
  end

  def base_url
    Rails.application.credentials.dig(:data_gouv_fr, :base_url) || 'https://demo.data.gouv.fr/api/1'
  end

  def api_key
    Rails.application.credentials.dig(:data_gouv_fr, :api_key)
  end

  def dataset_id
    Rails.application.credentials.dig(:data_gouv_fr, :dataset_slug) || 'habilitations-datapass-validees'
  end

  def resource_id
    Rails.application.credentials.dig(:data_gouv_fr, :resource_id) || demo_resource_id
  end

  def demo_resource_id
    'a9707b92-10fb-428e-8f59-c9e2af368e4f'
  end

  def upload_path
    "datasets/#{dataset_id}/resources/#{resource_id}/upload/"
  end

  def resource_path
    "datasets/#{dataset_id}/resources/#{resource_id}/"
  end

  def dataset_path
    "datasets/#{dataset_id}/"
  end

  def fetch_dataset
    response = connection.get(dataset_path)
    response.body.is_a?(Hash) ? response.body : JSON.parse(response.body.to_s)
  end
end
