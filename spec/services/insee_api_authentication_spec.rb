RSpec.describe INSEEAPIAuthentication do
  subject(:access_token) { described_class.new.access_token }

  let(:token_request_stub) do
    stub_request(:post, 'https://auth.insee.net/auth/realms/apim-gravitee/protocol/openid-connect/token').to_return(
      status: 200,
      headers: { 'Content-Type' => 'application/json' },
      body: { access_token: 'an_access_token' }.to_json,
    )
  end

  describe '#access_token' do
    context 'when INSEE answers with a token' do
      before { token_request_stub }

      it 'returns the token' do
        expect(access_token).to eq('an_access_token')
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

    context 'when the credentials come from the database' do
      before do
        token_request_stub
        Setting.set(:insee_password, 'rotated_password')
      end

      it 'sends the value stored in the database' do
        access_token

        expect(
          a_request(:post, 'https://auth.insee.net/auth/realms/apim-gravitee/protocol/openid-connect/token')
            .with(body: /password=rotated_password/)
        ).to have_been_made
      end
    end
  end
end
