require 'rails_helper'

RSpec.describe Developer::UpdateWebhook, type: :organizer do
  describe '.call' do
    subject(:result) do
      described_class.call(
        webhook: webhook,
        webhook_params: webhook_params
      )
    end

    let(:webhook) { create(:webhook, :active, url: 'https://old.webhook.site/test', events: %w[approve submit]) }

    context 'when only events are updated' do
      let(:webhook_params) do
        {
          url: 'https://old.webhook.site/test',
          events: %w[approve]
        }
      end

      it 'succeeds' do
        expect(result).to be_success
      end

      it 'updates the webhook' do
        result

        expect(webhook.reload.events).to eq(%w[approve])
      end

      it 'does not disable the webhook' do
        result

        expect(webhook.reload.enabled).to be(true)
        expect(webhook.validated).to be(true)
      end

      it 'does not test the webhook' do
        result

        expect(WebMock).not_to have_requested(:post, 'https://old.webhook.site/test')
      end
    end

    context 'when URL is updated and webhook test succeed' do
      let(:webhook_params) do
        {
          url: 'https://new.webhook.site/test',
          events: %w[approve submit]
        }
      end

      before do
        stub_request(:post, 'https://new.webhook.site/test').to_return(
          status: 200,
          body: '{"status": "ok"}'
        )
      end

      it { is_expected.to be_success }

      it 'updates the webhook' do
        result

        expect(webhook.reload.url).to eq('https://new.webhook.site/test')
      end

      it 'does not disable the webhook' do
        result

        expect(webhook.reload.enabled).to be(true)
        expect(webhook.validated).to be(true)
      end

      it 'tests the new webhook URL' do
        result

        expect(WebMock).to have_requested(:post, 'https://new.webhook.site/test').once
      end
    end

    context 'when URL is updated but test fails' do
      let(:webhook_params) do
        {
          url: 'https://new.webhook.site/test',
          events: %w[approve submit]
        }
      end

      before do
        stub_request(:post, 'https://new.webhook.site/test').to_return(
          status: 500,
          body: '{"error": "Internal Server Error"}'
        )
      end

      it { is_expected.to be_failure }

      it 'does not update the webhook' do
        result

        expect(webhook.reload.url).to eq('https://old.webhook.site/test')
      end
    end
  end
end
