require 'rails_helper'

RSpec.describe Developer::EnableWebhook, type: :interactor do
  describe '.call' do
    subject(:result) { described_class.call(webhook: webhook) }

    context 'when webhook is already validated and test succeeds' do
      let(:webhook) { create(:webhook, validated: true, enabled: false) }

      before do
        stub_request(:post, webhook.url).to_return(
          status: 200,
          body: '{"status": "ok"}'
        )
      end

      it { is_expected.to be_success }

      it 'enables the webhook' do
        result

        expect(webhook.reload.enabled).to be(true)
      end

      it 'tests the webhook' do
        result

        expect(WebMock).to have_requested(:post, webhook.url).once
      end
    end

    context 'when webhook is already validated but test fails' do
      let(:webhook) { create(:webhook, validated: true, enabled: false) }

      before do
        stub_request(:post, webhook.url).to_return(
          status: 500,
          body: '{"error": "Internal Server Error"}'
        )
      end

      it { is_expected.to be_failure }

      it 'does not enable the webhook' do
        result

        expect(webhook.reload.enabled).to be(false)
      end

      it 'returns webhook test results' do
        expect(result.webhook_test[:success]).to be(false)
        expect(result.webhook_test[:status_code]).to eq(500)
      end
    end

    context 'when webhook is not validated but test succeeds' do
      let(:webhook) { create(:webhook, validated: false, enabled: false) }

      before do
        stub_request(:post, webhook.url).to_return(
          status: 200,
          body: '{"status": "ok"}'
        )
      end

      it { is_expected.to be_success }

      it 'validates and enables the webhook' do
        result

        expect(webhook.reload.validated).to be(true)
        expect(webhook.reload.enabled).to be(true)
      end

      it 'tests the webhook' do
        result

        expect(WebMock).to have_requested(:post, webhook.url).once
      end
    end

    context 'when webhook is not validated and test fails' do
      let(:webhook) { create(:webhook, validated: false, enabled: false) }

      before do
        stub_request(:post, webhook.url).to_return(
          status: 500,
          body: '{"error": "Internal Server Error"}'
        )
      end

      it { is_expected.to be_failure }

      it 'does not validate or enable the webhook' do
        result

        expect(webhook.reload.validated).to be(false)
        expect(webhook.reload.enabled).to be(false)
      end

      it 'returns webhook test results' do
        expect(result.webhook_test[:success]).to be(false)
        expect(result.webhook_test[:status_code]).to eq(500)
      end
    end
  end
end
