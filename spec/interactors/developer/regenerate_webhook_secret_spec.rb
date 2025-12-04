require 'rails_helper'

RSpec.describe Developer::RegenerateWebhookSecret, type: :interactor do
  describe '.call' do
    subject(:result) do
      described_class.call(
        webhook: webhook
      )
    end

    let(:webhook) do
      create(:webhook, secret: 'old_secret_1234567890abcdef')
    end

    it { is_expected.to be_success }

    it 'regenerates the webhook secret' do
      old_secret = webhook.secret
      result
      webhook.reload

      expect(webhook.secret).not_to eq(old_secret)
      expect(webhook.secret).to be_present
      expect(webhook.secret).to be_a(String)
      expect(webhook.secret.length).to eq(64)
    end

    it 'exposes the new secret in the context' do
      expect(result.secret).to be_present
      expect(result.secret).to be_a(String)
      expect(result.secret.length).to eq(64)
      expect(result.secret).to eq(result.webhook.secret)
    end

    context 'when webhook update fails' do
      before do
        allow(webhook).to receive(:save).and_return(false)
      end

      it { is_expected.to be_failure }

      it 'returns the expected error' do
        expect(result.error).to eq(:invalid_webhook_model)
      end
    end
  end
end
