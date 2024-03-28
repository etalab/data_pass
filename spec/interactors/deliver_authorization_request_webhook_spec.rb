RSpec.describe DeliverAuthorizationRequestWebhook do
  describe '.call' do
    subject(:deliver_authorization_request_webhook) { described_class.call(authorization_request:, event_name:) }

    let(:authorization_request) { create(:authorization_request, :api_entreprise) }
    let(:event_name) { 'approve' }

    before do
      ActiveJob::Base.queue_adapter = :inline
    end

    after do
      ActiveJob::Base.queue_adapter = :test

      Rails.application.credentials.webhooks.api_entreprise.url = nil
      Rails.application.credentials.webhooks.api_entreprise.token = nil
    end

    describe 'when all env variables are set' do
      before do
        Rails.application.credentials.webhooks.api_entreprise.token = 'verify_token'
        Rails.application.credentials.webhooks.api_entreprise.url = webhook_url
      end

      let!(:webhook_post_request) do
        stub_request(:post, webhook_url).to_return(status: 200)
      end
      let(:webhook_url) { 'https://service.gouv.fr/webhook' }

      it 'calls the webhook' do
        deliver_authorization_request_webhook

        expect(webhook_post_request).to have_been_requested
      end
    end
  end
end
