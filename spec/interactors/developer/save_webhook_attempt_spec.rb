require 'rails_helper'

RSpec.describe Developer::SaveWebhookAttempt, type: :interactor do
  describe '.call' do
    subject(:result) do
      described_class.call(
        webhook: webhook,
        authorization_request: authorization_request,
        event_name: event_name,
        status_code: status_code,
        response_body: response_body,
        payload: payload
      )
    end

    let(:webhook) { create(:webhook) }
    let(:authorization_request) { create(:authorization_request, :api_entreprise) }
    let(:event_name) { 'approve' }
    let(:status_code) { 200 }
    let(:response_body) { '{"status": "ok"}' }
    let(:payload) { { event: 'approve', data: { id: 123 } } }

    it { is_expected.to be_success }

    it 'creates a webhook attempt' do
      expect { result }.to change(WebhookAttempt, :count).by(1)
    end

    it 'sets the correct attributes' do
      webhook_attempt = result.webhook_attempt

      expect(webhook_attempt.webhook).to eq(webhook)
      expect(webhook_attempt.authorization_request).to eq(authorization_request)
      expect(webhook_attempt.event_name).to eq(event_name)
      expect(webhook_attempt.status_code).to eq(status_code)
      expect(webhook_attempt.response_body).to eq(response_body)
      expect(webhook_attempt.payload).to eq(payload.deep_stringify_keys)
    end

    context 'when webhook attempt is invalid' do
      let(:webhook) { nil }

      it { is_expected.to be_failure }

      it 'fails with error' do
        expect(result.error).to eq(:invalid_webhook_attempt_model)
      end

      it 'does not create a webhook attempt' do
        expect { result }.not_to change(WebhookAttempt, :count)
      end
    end
  end
end
