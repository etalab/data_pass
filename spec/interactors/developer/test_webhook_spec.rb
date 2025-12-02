require 'rails_helper'

RSpec.describe Developer::TestWebhook, type: :interactor do
  describe '.call' do
    subject(:result) { described_class.call(webhook: webhook) }

    let(:webhook) { create(:webhook, :active) }

    before do
      stub_request(:post, webhook.url).to_return(
        status: 200,
        body: '{"status": "ok"}'
      )
    end

    it 'calls the webhook with test payload' do
      result

      expect(WebMock).to have_requested(:post, webhook.url).once
    end

    it 'does not create a webhook call' do
      expect { result }.not_to change(WebhookAttempt, :count)
    end

    it 'returns success status in webhook_test hash' do
      expect(result.webhook_test[:success]).to be(true)
      expect(result.webhook_test[:status_code]).to eq(200)
      expect(result.webhook_test[:response_body]).to eq('{"status": "ok"}')
    end

    context 'when webhook returns an error status' do
      before do
        stub_request(:post, webhook.url).to_return(
          status: 500,
          body: '{"error": "Internal Server Error"}'
        )
      end

      it 'returns failure status in webhook_test hash' do
        expect(result.webhook_test[:success]).to be(false)
        expect(result.webhook_test[:status_code]).to eq(500)
        expect(result.webhook_test[:response_body]).to eq('{"error": "Internal Server Error"}')
      end
    end

    context 'when webhook request fails with exception' do
      before do
        stub_request(:post, webhook.url).to_raise(Faraday::ConnectionFailed.new('Connection failed'))
      end

      it 'returns failure status with error message in webhook_test hash' do
        expect(result.webhook_test[:success]).to be(false)
        expect(result.webhook_test[:status_code]).to be_nil
        expect(result.webhook_test[:response_body]).to match(/Connection failed/)
      end
    end
  end
end
