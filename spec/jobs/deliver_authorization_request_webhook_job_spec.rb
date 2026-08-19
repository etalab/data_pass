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
    expect { deliver_authorization_request_webhook }.to change(WebhookAttempt, :count).by(1)

    webhook_attempt = WebhookAttempt.last
    expect(webhook_attempt.webhook).to eq(webhook)
    expect(webhook_attempt.authorization_request).to eq(authorization_request)
    expect(webhook_attempt.event_name).to eq(event_name)
    expect(webhook_attempt.status_code).to eq(status)
    expect(webhook_attempt.payload).to eq(payload)
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
      expect(Sentry).to receive(:capture_message).with("Fail to call target's api webhook endpoint")

      deliver_authorization_request_webhook
    end

    context 'when we reach the threshold to notify data provider' do
      before do
        job_instance.executions = described_class::THRESHOLD_TO_NOTIFY_DATA_PROVIDER - 1
      end

      it 'sends an email through WebhookMailer to developers' do
        expect {
          deliver_authorization_request_webhook
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

    context 'when the job has reached the maximum number of delivery attempts' do
      before do
        job_instance.executions = described_class::MAX_DELIVERY_ATTEMPTS - 1
        job_instance.exception_executions = {
          [described_class::WebhookDeliveryFailedError].to_s => described_class::MAX_DELIVERY_ATTEMPTS - 1
        }
      end

      it 'does not reschedule the job any further' do
        expect {
          deliver_authorization_request_webhook
        }.not_to have_enqueued_job(described_class)
      end

      it 'does not let the exception escape the job' do
        expect { deliver_authorization_request_webhook }.not_to raise_error
      end

      it 'does not let a failure of the abandon itself escape to the queue adapter' do
        allow(Developer::MarkWebhookAttemptAsAbandoned).to receive(:call).and_raise(ActiveRecord::StatementInvalid)
        allow(Sentry).to receive(:capture_exception)

        expect { deliver_authorization_request_webhook }.not_to raise_error
        expect(Sentry).to have_received(:capture_exception)
      end

      it 'marks the last webhook attempt as abandoned' do
        deliver_authorization_request_webhook

        expect(WebhookAttempt.last.abandoned_at).to be_present
      end

      it 'captures a distinct sentry message in level: :error with the delivery extras' do
        allow(Sentry).to receive(:set_extras)
        allow(Sentry).to receive(:capture_message)

        deliver_authorization_request_webhook

        expect(Sentry).to have_received(:capture_message).with('Webhook delivery abandoned after max attempts', level: :error)
        expect(Sentry).to have_received(:set_extras).with(
          hash_including(
            webhook_id: webhook.id,
            authorization_definition_id: webhook.authorization_definition_id,
            authorization_request_id: authorization_request.id,
            payload: payload,
            tries_count: described_class::MAX_DELIVERY_ATTEMPTS,
            webhook_response_status: status,
            webhook_response_body: response_body
          )
        ).twice
      end

      it 'still tracks the initial failure under its own distinct sentry message' do
        allow(Sentry).to receive(:set_extras)
        allow(Sentry).to receive(:capture_message)

        deliver_authorization_request_webhook

        expect(Sentry).to have_received(:capture_message).with("Fail to call target's api webhook endpoint")
      end
    end
  end

  context 'when the endpoint is unreachable (Faraday::ConnectionFailed)' do
    let(:status) { 500 }
    let(:response_body) { 'Internal Server Error' }

    before do
      stub_request(:post, webhook_url).to_raise(Faraday::ConnectionFailed.new('Connection refused'))
    end

    it 'creates a webhook attempt with status_code nil and the error class and message' do
      expect { deliver_authorization_request_webhook }.to change(WebhookAttempt, :count).by(1)

      webhook_attempt = WebhookAttempt.last
      expect(webhook_attempt.status_code).to be_nil
      expect(webhook_attempt.response_body).to eq('Faraday::ConnectionFailed: Connection refused')
    end

    it 'tracks the error on sentry' do
      expect(Sentry).to receive(:capture_message).with("Fail to call target's api webhook endpoint")

      deliver_authorization_request_webhook
    end

    it 'converts the network error into a bounded WebhookDeliveryFailedError instead of letting it escape' do
      expect(job_instance).to receive(:webhook_fail!).and_call_original

      expect { deliver_authorization_request_webhook }.not_to raise_error
    end

    it 'reschedules the job like any other failure' do
      expect { deliver_authorization_request_webhook }.to have_enqueued_job(described_class)
    end
  end

  context 'when the endpoint times out (Faraday::TimeoutError)' do
    before do
      stub_request(:post, webhook_url).to_raise(Faraday::TimeoutError.new('execution expired'))
    end

    it 'creates a webhook attempt with status_code nil identifying the timeout' do
      deliver_authorization_request_webhook

      webhook_attempt = WebhookAttempt.last
      expect(webhook_attempt.status_code).to be_nil
      expect(webhook_attempt.response_body).to eq('Faraday::TimeoutError: execution expired')
    end

    it 'follows the same bounded retry path as any other failure' do
      expect { deliver_authorization_request_webhook }.to have_enqueued_job(described_class)
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
