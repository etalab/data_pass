RSpec.describe APICaptchEtatBridge, type: :bridge do
  let(:authorization_request) { create(:authorization_request, :api_captchetat) }
  let(:external_provider_id) { SecureRandom.uuid }
  let(:create_subscription_piste_payload) do
    {
      'approval_id' => authorization_request.id,
      'status' => 'success',
      'user_created' => 'true',
      'application_created' => 'true',
      'granted_user' => authorization_request.contact_technique_email,
      'granted_prd_application' => "APP_DATAPASS_#{authorization_request.id}_#{authorization_request.contact_technique_email}",
      'granted_sbx_application' => "APP_DATAPASS_SBX_#{authorization_request.id}_#{authorization_request.contact_technique_email}",
      'granted_api' => 'CaptchEtat v2',
      'piste_api_link' => 'https://rec.piste.gouv.fr/api-center?filter=CaptchEtat%20v2',
      'piste_app_prd_link' => "https://rec.piste.gouv.fr/apps/application/view/#{external_provider_id}",
      'piste_app_sbx_link' => 'https =>//rec.piste.gouv.fr/apps/application/view/c3b988fc-6fb6-4ce0-aa5a-68d831403e6c?api-manager=2'
    }
  end

  describe '#on_approve' do
    subject(:trigger_bridge) { described_class.new.perform(authorization_request, 'approve') }

    before do
      allow(PISTEAPIClient).to receive(:create_subscription).and_return(create_subscription_piste_payload)
    end

    it 'affects external_provider_id to authorization request' do
      expect {
        trigger_bridge
      }.to change { authorization_request.reload.external_provider_id }.from(nil).to(external_provider_id)
    end
  end

  describe 'when PISTE fails' do
    subject(:run_bridge_job) { bridge_job.perform_now }

    let(:bridge_job) { described_class.new(authorization_request, 'approve') }

    before do
      allow(PISTEAPIClient).to receive(:create_subscription).and_raise(error)
      allow(Sentry).to receive(:capture_exception)
    end

    shared_examples 'a failure reported to Sentry right away' do
      it 'reports the error to Sentry on the first attempt' do
        run_bridge_job
      rescue error.class
        nil
      ensure
        expect(Sentry).to have_received(:capture_exception).with(error, hash_including(tags: hash_including(bridge: 'APICaptchEtatBridge')))
      end
    end

    shared_examples 'a failure that is not retried' do
      it 'does not retry the job' do
        expect { run_bridge_job }.not_to have_enqueued_job(described_class)
      end
    end

    context 'when PISTE quota is exceeded' do
      let(:error) { Faraday::TooManyRequestsError.new(nil, { status: 429, body: '' }) }

      it_behaves_like 'a failure reported to Sentry right away'

      it 'retries the job later' do
        freeze_time do
          expect { run_bridge_job }.to have_enqueued_job(described_class).at(a_value_within(1.hour).of(described_class::WAIT_BETWEEN_ATTEMPTS.from_now))
        end
      end

      it 'leaves the authorization request without PISTE application' do
        run_bridge_job

        expect(authorization_request.reload.external_provider_id).to be_nil
      end

      context 'when the last attempt fails' do
        before do
          bridge_job.exception_executions[[Faraday::TooManyRequestsError, Faraday::ConnectionFailed].to_s] = described_class::MAX_ATTEMPTS - 1
        end

        it 'stops retrying' do
          expect {
            expect { run_bridge_job }.to raise_error(Faraday::TooManyRequestsError)
          }.not_to have_enqueued_job(described_class)
        end
      end
    end

    context 'when the connection to PISTE cannot be opened' do
      let(:error) { Faraday::ConnectionFailed.new('execution expired') }

      it 'retries the job later' do
        expect { run_bridge_job }.to have_enqueued_job(described_class)
      end
    end

    context 'when PISTE does not answer in time' do
      let(:error) { Faraday::TimeoutError.new('Net::ReadTimeout') }

      it_behaves_like 'a failure reported to Sentry right away'
      it_behaves_like 'a failure that is not retried'
    end

    context 'when PISTE answers with a server error' do
      let(:error) { Faraday::ServerError.new(nil, { status: 504, body: '<html>Gateway Timeout</html>' }) }

      it_behaves_like 'a failure that is not retried'
    end

    context 'when PISTE answers without the production application link' do
      let(:error) { PISTEAPIClient::InvalidResponseError.new('PISTE response without piste_app_prd_link') }

      it_behaves_like 'a failure that is not retried'
    end

    context 'with a definitive client error' do
      let(:error) { Faraday::BadRequestError.new(nil, { status: 400, body: 'invalid approval_id' }) }

      it_behaves_like 'a failure that is not retried'

      it 'reports the HTTP status to Sentry' do
        run_bridge_job

        expect(Sentry).to have_received(:capture_exception).with(error, hash_including(contexts: { bridge: hash_including(http_status: 400) }))
      end
    end
  end
end
