RSpec.describe INSEESireneAPIClient do
  before do
    allow(INSEEAPIAuthentication).to receive(:access_token).and_return('access_token')
  end

  describe '#etablissement' do
    subject(:etablissement_payload) { described_class.new.etablissement(siret:) }

    let(:siret) { generate(:siret) }

    context 'when the API returns a 200' do
      let(:valid_payload) { insee_sirene_api_etablissement_valid_payload(siret:) }

      before do
        stub_request(:get, "https://api.insee.fr/api-sirene/prive/3.11/siret/#{siret}").to_return(
          status: 200,
          headers: { 'Content-Type' => 'application/json' },
          body: valid_payload.to_json
        )
      end

      it 'renders a valid json from payload' do
        expect(etablissement_payload).to eq(valid_payload)
      end
    end

    context 'when API returns a 404' do
      before do
        stub_request(:get, "https://api.insee.fr/api-sirene/prive/3.11/siret/#{siret}").to_return(
          status: 404,
          headers: { 'Content-Type' => 'application/json' },
          body: ''
        )
      end

      it 'raises an EntityNotFoundError' do
        expect { etablissement_payload }.to raise_error(INSEESireneAPIClient::EntityNotFoundError)
      end
    end

    context 'when API returns something else than 200 and 404' do
      before do
        stub_request(:get, "https://api.insee.fr/api-sirene/prive/3.11/siret/#{siret}").to_return(
          status: 405,
          headers: { 'Content-Type' => 'application/json' },
          body: ''
        )
      end

      it 'raises an error' do
        expect { etablissement_payload }.to raise_error(Faraday::Error)
      end

      it 'does not retry a request INSEE has already refused' do
        expect { etablissement_payload }.to raise_error(Faraday::Error)

        expect(a_request(:get, "https://api.insee.fr/api-sirene/prive/3.11/siret/#{siret}")).to have_been_made.once
      end
    end

    context 'when API returns a 401' do
      before do
        stub_request(:get, "https://api.insee.fr/api-sirene/prive/3.11/siret/#{siret}").to_return(
          status: 401,
          headers: { 'Content-Type' => 'application/json' },
          body: ''
        )
        allow(INSEEAPIAuthentication).to receive(:invalidate_access_token!)
        allow(Sentry).to receive(:capture_exception)
      end

      it 'raises an UnavailableError' do
        expect { etablissement_payload }.to raise_error(AbstractINSEEAPIClient::UnavailableError)
      end

      it 'pauses the INSEE calls' do
        expect { etablissement_payload }.to raise_error(AbstractINSEEAPIClient::UnavailableError)

        expect(INSEECallsPause).to be_paused
      end

      it 'invalidates the cached access token' do
        expect { etablissement_payload }.to raise_error(AbstractINSEEAPIClient::UnavailableError)

        expect(INSEEAPIAuthentication).to have_received(:invalidate_access_token!)
      end
    end

    context 'when API returns HTML instead of JSON' do
      before do
        stub_request(:get, "https://api.insee.fr/api-sirene/prive/3.11/siret/#{siret}").to_return(
          status: 200,
          headers: { 'Content-Type' => 'text/html' },
          body: '<!DOCTYPE html><html><body>Service unavailable</body></html>'
        )
      end

      it 'raises an InvalidResponseError' do
        expect { etablissement_payload }.to raise_error(INSEESireneAPIClient::InvalidResponseError)
      end
    end

    context 'when the INSEE calls are disabled by configuration' do
      before do
        stub_request(:get, %r{^https://api.insee.fr/api-sirene/prive/3.11/siret/})
        Setting.set(:insee_calls_enabled, 'false')
      end

      it 'raises an UnavailableError without calling INSEE' do
        expect { etablissement_payload }.to raise_error(AbstractINSEEAPIClient::UnavailableError)

        expect(a_request(:get, %r{^https://api.insee.fr/api-sirene/prive/3.11/siret/})).not_to have_been_made
      end

      it 'counts the skipped call' do
        expect { etablissement_payload }.to raise_error(AbstractINSEEAPIClient::UnavailableError)

        expect(INSEECallsPause.skipped_calls_count).to eq(1)
      end
    end

    context 'when INSEE calls are paused' do
      before do
        stub_request(:get, %r{^https://api.insee.fr/api-sirene/prive/3.11/siret/})
        INSEECallsPause.pause!
      end

      it 'raises an UnavailableError without calling INSEE' do
        expect { etablissement_payload }.to raise_error(AbstractINSEEAPIClient::UnavailableError)

        expect(a_request(:get, %r{^https://api.insee.fr/api-sirene/prive/3.11/siret/})).not_to have_been_made
      end

      it 'counts the skipped call' do
        expect { etablissement_payload }.to raise_error(AbstractINSEEAPIClient::UnavailableError)

        expect(INSEECallsPause.skipped_calls_count).to eq(1)
      end
    end
  end
end
