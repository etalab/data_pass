require 'rails_helper'

RSpec.describe DeliverAuthorizationRequestWebhookJob do
  subject(:deliver_authorization_request_webhook) { job_instance.perform_now }

  before do
    ActiveJob::Base.queue_adapter = :inline
  end

  after do
    ActiveJob::Base.queue_adapter = :test

    Rails.application.credentials.webhooks.api_entreprise.url = nil
    Rails.application.credentials.webhooks.api_entreprise.token = nil
  end

  let(:job_instance) { described_class.new(target_api, payload.to_json, authorization_request.id) }
  let(:target_api) { 'api_entreprise' }
  let(:payload) do
    {
      'lol' => 'oki'
    }
  end

  let(:authorization_request) { create(:authorization_request, :api_entreprise, :api_entreprise_mgdis) }
  let!(:webhook_post_request) do
    stub_request(:post, webhook_url).with(
      body: payload.to_json,
      headers: {
        'Content-Type' => 'application/json',
        'X-Hub-Signature-256' => "sha256=#{hub_signature}"
      }
    ).to_return(status:)
  end
  let(:status) { [200, 201, 204].sample }
  let(:webhook_url) { 'https://service.gouv.fr/path/to/webhook' }
  let(:verify_token) { 'verify_token' }
  let(:hub_signature) do
    OpenSSL::HMAC.hexdigest(
      OpenSSL::Digest.new('sha256'),
      verify_token,
      payload.to_json
    )
  end

  context "when target api's webhook url is not defined" do
    before do
      Rails.application.credentials.webhooks.api_entreprise.token = verify_token
    end

    it 'does nothing' do
      deliver_authorization_request_webhook

      expect(webhook_post_request).not_to have_been_requested
    end
  end

  context "when target api's verify token is not defined" do
    before do
      Rails.application.credentials.webhooks.api_entreprise.url = webhook_url
    end

    it 'does nothing' do
      deliver_authorization_request_webhook

      expect(webhook_post_request).not_to have_been_requested
    end
  end

  context 'when all target api webhook env vars are defined' do
    before do
      Rails.application.credentials.webhooks.api_entreprise.url = webhook_url
      Rails.application.credentials.webhooks.api_entreprise.token = verify_token
    end

    it "performs a post request on target api's webhook url with payload and headers" do
      deliver_authorization_request_webhook

      expect(webhook_post_request).to have_been_requested
    end

    describe "target's api webhook url status" do
      before do
        allow(job_instance).to receive(:webhook_fail!)
      end

      context 'when endpoint respond with a success' do
        it 'does not reschedule worker' do
          expect(job_instance).not_to receive(:webhook_fail!)

          deliver_authorization_request_webhook
        end

        it 'does not track on sentry' do
          expect(Sentry).not_to receive(:capture_message)

          deliver_authorization_request_webhook
        end

        context 'when body is a json with a token_id key' do
          let!(:webhook_post_request) do
            stub_request(:post, webhook_url).to_return(status: 200, body: { token_id: 'token_id' }.to_json)
          end

          it 'stores this token id in authorization_request' do
            expect {
              deliver_authorization_request_webhook
            }.to change { authorization_request.reload.linked_token_manager_id }.to('token_id')
          end
        end
      end

      context 'when endpoint respond with an error (400 to 599 status)' do
        let(:status) { rand(400..599) }

        it 'reschedules job' do
          expect(job_instance).to receive(:webhook_fail!)

          deliver_authorization_request_webhook
        end

        it 'tracks on sentry' do
          expect(Sentry).to receive(:capture_message)

          deliver_authorization_request_webhook
        end

        context 'when last retry_on attempt fails' do
          let(:tries_count) { described_class::TOTAL_ATTEMPTS }
          let(:response) { instance_double(Faraday::Response, status:, body: 'body') }

          before do
            allow(job_instance).to receive_messages(request: response, attempts: described_class::TOTAL_ATTEMPTS)

            ActiveJob::Base.queue_adapter = :test
          end

          it 'sends an email through WebhookMailer to instructors' do
            deliver_authorization_request_webhook

            expect(ActionMailer::MailDeliveryJob).to(
              have_been_enqueued.with(
                'WebhookMailer',
                'fail',
                'deliver_now',
                {
                  params: {
                    target_api:,
                    payload:,
                    webhook_response_status: status,
                    webhook_response_body: 'body',
                  },
                  args: []
                }
              )
            )
          end
        end
      end
    end
  end
end
