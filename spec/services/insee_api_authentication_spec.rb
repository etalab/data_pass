RSpec.describe INSEEAPIAuthentication do
  let(:token_request_stub) do
    stub_request(:post, described_class::TOKEN_URL).to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: { access_token: 'an_access_token', expires_in: 3600 }.to_json,
    )
  end

  describe '.access_token' do
    subject(:access_token) { described_class.access_token }

    context 'when INSEE answers with a token' do
      before { token_request_stub }

      it 'returns the token' do
        expect(access_token).to eq('an_access_token')
      end

      it 'requests the token only once for subsequent calls' do
        3.times { described_class.access_token }

        expect(token_request_stub).to have_been_requested.once
      end

      it 'requests a new token once the cached one has expired' do
        described_class.access_token

        travel_to(2.hours.from_now) { described_class.access_token }

        expect(token_request_stub).to have_been_requested.twice
      end
    end

    context 'when INSEE does not announce any expiration' do
      before do
        stub_request(:post, described_class::TOKEN_URL).to_return(
          status: 200,
          headers: { 'Content-Type' => 'application/json' },
          body: { access_token: 'an_access_token' }.to_json,
        )
      end

      it 'caches the token for a short fallback duration' do
        described_class.access_token

        travel_to(described_class::FALLBACK_TOKEN_LIFETIME.from_now + 1.second) { described_class.access_token }

        expect(a_request(:post, described_class::TOKEN_URL)).to have_been_made.twice
      end
    end

    context 'when INSEE answers 200 with something else than a JSON object' do
      before do
        stub_request(:post, described_class::TOKEN_URL).to_return(
          status: 200,
          headers: { 'Content-Type' => 'text/html' },
          body: '<!DOCTYPE html><html><body>access_token</body></html>',
        )
      end

      it 'raises an InvalidResponseError' do
        expect { access_token }.to raise_error(AbstractINSEEAPIClient::InvalidResponseError)
      end

      it 'does not cache anything' do
        expect { access_token }.to raise_error(AbstractINSEEAPIClient::InvalidResponseError)
        expect { described_class.access_token }.to raise_error(AbstractINSEEAPIClient::InvalidResponseError)

        expect(a_request(:post, described_class::TOKEN_URL)).to have_been_made.twice
      end

      it 'does not pause the INSEE calls' do
        expect { access_token }.to raise_error(AbstractINSEEAPIClient::InvalidResponseError)

        expect(INSEECallsPause).not_to be_paused
      end
    end

    context 'when INSEE answers 200 without an access token' do
      before do
        stub_request(:post, described_class::TOKEN_URL).to_return(
          status: 200,
          headers: { 'Content-Type' => 'application/json' },
          body: { error: 'invalid_grant' }.to_json,
        )
      end

      it 'raises an InvalidResponseError' do
        expect { access_token }.to raise_error(AbstractINSEEAPIClient::InvalidResponseError)
      end
    end

    context 'when the credentials come from the database' do
      before do
        token_request_stub
        Setting.set(:insee_password, 'rotated_password')
      end

      it 'sends the value stored in the database' do
        access_token

        expect(
          a_request(:post, described_class::TOKEN_URL).with(body: /password=rotated_password/)
        ).to have_been_made
      end
    end

    context 'when INSEE rejects the credentials with a 400' do
      before do
        stub_request(:post, described_class::TOKEN_URL).to_return(status: 400)
        allow(Sentry).to receive(:capture_exception)
      end

      it 'raises an UnavailableError' do
        expect { access_token }.to raise_error(AbstractINSEEAPIClient::UnavailableError)
      end

      it 'does not retry the rejected request' do
        expect { access_token }.to raise_error(AbstractINSEEAPIClient::UnavailableError)

        expect(a_request(:post, described_class::TOKEN_URL)).to have_been_made.once
      end

      it 'pauses the INSEE calls' do
        expect { access_token }.to raise_error(AbstractINSEEAPIClient::UnavailableError)

        expect(INSEECallsPause).to be_paused
      end

      it 'reports to Sentry' do
        expect { access_token }.to raise_error(AbstractINSEEAPIClient::UnavailableError)

        expect(Sentry).to have_received(:capture_exception).with(an_instance_of(Faraday::BadRequestError))
      end
    end

    context 'when INSEE rejects the credentials with a 401' do
      before do
        stub_request(:post, described_class::TOKEN_URL).to_return(status: 401)
        allow(Sentry).to receive(:capture_exception)
      end

      it 'pauses the INSEE calls' do
        expect { access_token }.to raise_error(AbstractINSEEAPIClient::UnavailableError)

        expect(INSEECallsPause).to be_paused
      end
    end

    context 'when the INSEE calls are disabled by configuration' do
      before do
        token_request_stub
        Setting.set(:insee_calls_enabled, 'false')
      end

      it 'raises an UnavailableError without calling INSEE' do
        expect { access_token }.to raise_error(AbstractINSEEAPIClient::UnavailableError)

        expect(token_request_stub).not_to have_been_requested
      end
    end

    context 'when INSEE calls are paused' do
      before do
        token_request_stub
        INSEECallsPause.pause!
      end

      it 'raises an UnavailableError without calling INSEE' do
        expect { access_token }.to raise_error(AbstractINSEEAPIClient::UnavailableError)

        expect(token_request_stub).not_to have_been_requested
      end

      it 'counts the skipped call' do
        expect { access_token }.to raise_error(AbstractINSEEAPIClient::UnavailableError)

        expect(INSEECallsPause.skipped_calls_count).to eq(1)
      end
    end
  end
end
