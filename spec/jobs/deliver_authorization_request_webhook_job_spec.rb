require 'rails_helper'

RSpec.describe DeliverAuthorizationRequestWebhookJob do
  subject(:deliver_authorization_request_webhook) { job_instance.perform_now }

  let(:job_instance) { described_class.new(webhook.id, authorization_request.id, event_name, payload) }
  let(:hub_signature) do
    OpenSSL::HMAC.hexdigest(
      OpenSSL::Digest.new('sha256'),
      verify_token,
      payload.to_json
    )
  end
  let(:event_name) { 'create' }
  let(:payload) do
    {
      'event' => event_name,
      'lol' => 'oki'
    }
  end

  let(:authorization_request) { create(:authorization_request, :api_entreprise, :api_entreprise_mgdis) }
  let(:webhook) { create(:webhook, url: webhook_url, secret: verify_token, authorization_definition_id: 'api_entreprise') }
  let(:webhook_post_request) do
    stub_request(:post, webhook_url).with(
      body: payload.to_json
    ).to_return(status:, body: response_body)
  end
  let(:status) { [200, 201, 204].sample }
  let(:response_body) { '' }
  let(:webhook_url) { 'https://service.gouv.fr/path/to/webhook?hello=world' }
  let(:verify_token) { 'verify_token' }

  before do
    webhook_post_request
  end

  it 'performs a post request on webhook url with payload and headers' do
    deliver_authorization_request_webhook

    expect(webhook_post_request).to have_been_requested
  end

  it 'creates a webhook call record' do
    expect { deliver_authorization_request_webhook }.to change(WebhookCall, :count).by(1)

    webhook_call = WebhookCall.last
    expect(webhook_call.webhook).to eq(webhook)
    expect(webhook_call.authorization_request).to eq(authorization_request)
    expect(webhook_call.event_name).to eq(event_name)
    expect(webhook_call.status_code).to eq(status)
    expect(webhook_call.payload).to eq(payload)
  end

  context 'when endpoint respond with an error (400 to 599 status)' do
    let(:status) { 500 }
    let(:response_body) { 'Internal Server Error' }

    it 'reschedules job' do
      expect(job_instance).to receive(:webhook_fail!).and_call_original

      expect {
        deliver_authorization_request_webhook
      }.not_to raise_error
    end

    it 'tracks on sentry' do
      expect(Sentry).to receive(:capture_message)

      begin
        deliver_authorization_request_webhook
      rescue DeliverAuthorizationRequestWebhookJob::WebhookDeliveryFailedError
        # ignore
      end
    end

    context 'when we reach the threshold to notify data provider' do
      before do
        allow(job_instance).to receive(:attempts).and_return(DeliverAuthorizationRequestWebhookJob::THRESHOLD_TO_NOTIFY_DATA_PROVIDER)
      end

      it 'sends an email through WebhookMailer to developers' do
        expect {
          begin
            deliver_authorization_request_webhook
          rescue DeliverAuthorizationRequestWebhookJob::WebhookDeliveryFailedError
            # ignore
          end
        }.to have_enqueued_job(ActionMailer::MailDeliveryJob).with(
          'WebhookMailer',
          'fail',
          'deliver_now',
          hash_including(
            params: hash_including(
              webhook: webhook
            )
          )
        )
      end
    end
  end

  context 'when body is a json with a token_id key' do
    let(:status) { 200 }
    let(:response_body) { { token_id: 'token_id' }.to_json }

    it 'stores this token id in authorization_request' do
      expect {
        deliver_authorization_request_webhook
      }.to change { authorization_request.reload.external_provider_id }.to('token_id')
    end
  end
end
