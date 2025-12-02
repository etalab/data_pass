require 'rails_helper'

RSpec.describe Developer::ReplayWebhookAttempt, type: :interactor do
  describe '.call' do
    subject(:result) { described_class.call(webhook_attempt: webhook_attempt) }

    let(:webhook) { create(:webhook, :active) }
    let(:authorization_request) { create(:authorization_request, :api_entreprise) }
    let!(:webhook_attempt) { create(:webhook_attempt, webhook: webhook, authorization_request: authorization_request) }

    context 'when request succeeds' do
      before do
        stub_request(:post, webhook.url).to_return(
          status: 200,
          body: '{"status": "ok"}'
        )
      end

      it { is_expected.to be_success }

      it 'creates a new webhook attempt' do
        expect { result }.to change(WebhookAttempt, :count).by(1)
      end

      it 'calls the webhook with the original payload' do
        result

        expect(WebMock).to have_requested(:post, webhook.url).once
      end

      it 'saves the new webhook attempt with the response' do
        new_webhook_attempt = result.webhook_attempt

        expect(new_webhook_attempt.webhook).to eq(webhook)
        expect(new_webhook_attempt.authorization_request).to eq(authorization_request)
        expect(new_webhook_attempt.event_name).to eq(webhook_attempt.event_name)
        expect(new_webhook_attempt.status_code).to eq(200)
        expect(new_webhook_attempt.response_body).to eq('{"status": "ok"}')
        expect(new_webhook_attempt.payload).to eq(webhook_attempt.payload)
      end
    end

    context 'when request returns non-2XX status' do
      before do
        stub_request(:post, webhook.url).to_return(
          status: 422,
          body: '{"error": "validation failed"}'
        )
      end

      it { is_expected.to be_success }

      it 'creates a new webhook attempt with error status' do
        new_webhook_attempt = result.webhook_attempt

        expect(new_webhook_attempt.status_code).to eq(422)
        expect(new_webhook_attempt.response_body).to eq('{"error": "validation failed"}')
        expect(new_webhook_attempt.success?).to be false
      end
    end

    context 'when webhook request fails' do
      before do
        stub_request(:post, webhook.url).to_raise(Faraday::ConnectionFailed.new('Connection refused'))
      end

      it { is_expected.to be_failure }

      it 'fails with error and message' do
        expect(result.error).to eq(:webhook_request_failed)
        expect(result.message).to match(/Connection refused/)
      end

      it 'does not create a new webhook attempt' do
        expect { result }.not_to change(WebhookAttempt, :count)
      end
    end
  end
end
