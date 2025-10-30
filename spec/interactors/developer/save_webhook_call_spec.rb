require 'rails_helper'

RSpec.describe Developer::SaveWebhookCall, type: :interactor do
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

    it 'creates a webhook call' do
      expect { result }.to change(WebhookCall, :count).by(1)
    end

    it 'sets the correct attributes' do
      webhook_call = result.webhook_call

      expect(webhook_call.webhook).to eq(webhook)
      expect(webhook_call.authorization_request).to eq(authorization_request)
      expect(webhook_call.event_name).to eq(event_name)
      expect(webhook_call.status_code).to eq(status_code)
      expect(webhook_call.response_body).to eq(response_body)
      expect(webhook_call.payload).to eq(payload.deep_stringify_keys)
    end

    context 'when webhook call is invalid' do
      let(:webhook) { nil }

      it { is_expected.to be_failure }

      it 'fails with error' do
        expect(result.error).to eq(:invalid_webhook_call_model)
      end

      it 'does not create a webhook call' do
        expect { result }.not_to change(WebhookCall, :count)
      end
    end
  end
end
