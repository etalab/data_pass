class WebhookHttpService
  attr_reader :url, :secret

  def initialize(url, secret)
    @url = url
    @secret = secret
  end

  def call(payload_hash)
    payload_json = payload_hash.to_json
    signature = calculate_signature(payload_json)

    response = faraday_client.post do |req|
      req.headers['Content-Type'] = 'application/json'
      req.headers['X-Hub-Signature-256'] = signature
      req.headers['X-App-Environment'] = Rails.env
      req.body = payload_json
    end

    {
      status_code: response.status,
      response_body: response.body
    }
  end

  private

  def calculate_signature(payload_json)
    hmac = OpenSSL::HMAC.hexdigest('SHA256', secret, payload_json)
    "sha256=#{hmac}"
  end

  def faraday_client
    Faraday.new(url: url) do |faraday|
      faraday.adapter Faraday.default_adapter
    end
  end
end
