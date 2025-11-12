require 'rails_helper'

RSpec.describe Developer::CreateWebhookModel, type: :interactor do
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

    it { is_expected.to be_success }

    it 'creates a webhook with correctb attributes' do
      expect { result }.to change(Webhook, :count).by(1)

      webhook = result.webhook

      expect(webhook.authorization_definition_id).to eq('api_entreprise')
      expect(webhook.url).to eq('https://webhook.site/test')
      expect(webhook.events).to eq(%w[approve submit])
      expect(webhook.secret).to be_present
      expect(webhook.validated).to be(false)
      expect(webhook.enabled).to be(false)
      expect(webhook.secret).to be_a(String)
      expect(webhook.secret.length).to eq(64)
    end

    context 'when webhook params are invalid' do
      let(:webhook_params) do
        {
          authorization_definition_id: '',
          url: '',
          events: []
        }
      end

      it { is_expected.to be_failure }

      it 'does not create a webhook' do
        expect { result }.not_to change(Webhook, :count)
      end
    end
  end
end
