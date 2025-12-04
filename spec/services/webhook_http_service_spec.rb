require 'rails_helper'

RSpec.describe WebhookHttpService do
  let(:url) { 'https://webhook.site/test' }
  let(:secret) { 'test_secret_token' }
  let(:service) { described_class.new(url, secret) }
  let(:payload) { { event: 'approve', data: { id: 123 } } }

  describe '#call' do
    context 'when the request is successful' do
      before do
        stub_request(:post, url).to_return(
          status: 200,
          body: '{"status": "ok"}'
        )
      end

      it 'returns status code and response body with correct headers' do
        result = service.call(payload)

        expect(result[:status_code]).to eq(200)
        expect(result[:response_body]).to eq('{"status": "ok"}')

        payload_json = payload.to_json
        expected_signature = "sha256=#{OpenSSL::HMAC.hexdigest('SHA256', secret, payload_json)}"

        expect(WebMock).to have_requested(:post, url).with(
          headers: {
            'Content-Type' => 'application/json',
            'X-Hub-Signature-256' => expected_signature,
            'X-App-Environment' => Rails.env
          },
          body: payload_json
        )
      end
    end

    context 'when the request fails' do
      before do
        stub_request(:post, url).to_raise(Faraday::ConnectionFailed.new('Connection refused'))
      end

      it 'raises the error without catching it' do
        expect { service.call(payload) }.to raise_error(Faraday::ConnectionFailed, /Connection refused/)
      end
    end
  end
end
