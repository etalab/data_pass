require 'rails_helper'

RSpec.describe Developer::CreateWebhook, type: :organizer do
  describe '.call' do
    subject(:result) do
      described_class.call(
        webhook_params: webhook_params
      )
    end

    let(:webhook_params) do
      {
        authorization_definition_id: 'api_entreprise',
        url: 'https://webhook.site/test',
        events: %w[approve submit]
      }
    end

    before do
      stub_request(:post, 'https://webhook.site/test').to_return(
        status: 200,
        body: '{"status": "ok"}'
      )
    end

    it { is_expected.to be_success }

    it 'creates a webhook' do
      expect { result }.to change(Webhook, :count).by(1)
    end

    it 'marks webhook as validated and not enabled' do
      webhook = result.webhook

      expect(webhook.validated).to be(true)
      expect(webhook.enabled).to be(false)
    end

    it 'tests the webhook' do
      result

      expect(WebMock).to have_requested(:post, 'https://webhook.site/test').once
    end

    context 'when webhook test fails' do
      before do
        stub_request(:post, 'https://webhook.site/test').to_return(
          status: 500,
          body: '{"error": "Internal Server Error"}'
        )
      end

      it { is_expected.to be_success }

      it 'creates a webhook' do
        expect { result }.to change(Webhook, :count).by(1)
      end

      it 'does not mark webhook as validated' do
        webhook = result.webhook

        expect(webhook.validated).to be(false)
      end
    end
  end
end
