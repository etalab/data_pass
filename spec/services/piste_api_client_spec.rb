RSpec.describe PISTEAPIClient do
  subject(:create_subscription) { described_class.create_subscription(authorization_request) }

  let(:authorization_request) { create(:authorization_request, :api_captchetat, :validated) }
  let(:oauth_url) { 'https://oauth.piste.example/api/oauth/token' }
  let(:approve_url) { 'https://api.piste.example/datapass/v1/approve' }
  let(:json_headers) { { 'Content-Type' => 'application/json' } }
  let(:approve_payload) do
    {
      'status' => 'success',
      'piste_app_prd_link' => 'https://piste.example/apps/application/view/some-uuid'
    }
  end

  before do
    allow(Rails.application.credentials).to receive_messages(
      piste_oauth_url: oauth_url,
      piste_create_subscription_url: approve_url,
      piste_client_id: 'client_id',
      piste_client_secret: 'client_secret',
    )
  end

  def stub_token(status: 200, body: { access_token: 'piste_token' }.to_json)
    stub_request(:post, oauth_url).to_return(status:, body:, headers: json_headers)
  end

  def stub_approve(status: 200, body: approve_payload.to_json, headers: json_headers)
    stub_request(:post, approve_url).to_return(status:, body:, headers:)
  end

  context 'when PISTE accepts the subscription' do
    before do
      stub_token
      stub_approve
    end

    it 'returns the PISTE payload' do
      expect(create_subscription).to eq(approve_payload)
    end

    it 'sends the contact technique email, the approval id and the API name with the bearer token' do
      create_subscription

      expect(
        a_request(:post, approve_url).with(
          headers: { 'Authorization' => 'Bearer piste_token' },
          body: {
            requestor_email: authorization_request.contact_technique_email,
            approval_id: authorization_request.latest_authorization.id,
            api_name: 'CaptchEtat v2'
          }.to_json,
        )
      ).to have_been_made.once
    end
  end

  context 'when the PISTE API name setting is overridden' do
    before do
      allow(Setting).to receive(:fetch).and_call_original
      allow(Setting).to receive(:fetch).with(:piste_api_name).and_return('CaptchEtat v3')
      stub_token
      stub_approve
    end

    it 'sends the overridden API name' do
      create_subscription

      expect(a_request(:post, approve_url).with(body: hash_including('api_name' => 'CaptchEtat v3'))).to have_been_made.once
    end
  end

  context 'when PISTE answers with too many requests' do
    before do
      stub_token
      stub_approve(status: 429, body: { error: 'quota exceeded' }.to_json)
    end

    it 'raises a too many requests error carrying the HTTP status' do
      expect { create_subscription }.to raise_error(Faraday::TooManyRequestsError) { |error|
        expect(error.response_status).to eq(429)
      }
    end
  end

  context 'when the PISTE gateway times out with an HTML page' do
    before do
      stub_token
      stub_approve(status: 504, body: '<html>Gateway Timeout</html>', headers: { 'Content-Type' => 'text/html' })
    end

    it 'raises a server error' do
      expect { create_subscription }.to raise_error(Faraday::ServerError)
    end
  end

  context 'when PISTE answers successfully without the production application link' do
    before do
      stub_token
      stub_approve(body: { status: 'failure' }.to_json)
    end

    it 'raises an invalid response error describing the payload' do
      expect { create_subscription }.to raise_error(described_class::InvalidResponseError, /piste_app_prd_link.*"failure"/)
    end
  end

  context 'when the token request is rejected' do
    before do
      stub_token(status: 401, body: { error: 'invalid_client' }.to_json)
      stub_approve
    end

    it 'raises an unauthorized error without calling approve' do
      expect { create_subscription }.to raise_error(Faraday::UnauthorizedError)
      expect(a_request(:post, approve_url)).not_to have_been_made
    end
  end

  context 'when the token response has no access token' do
    before do
      stub_token(body: {}.to_json)
      stub_approve
    end

    it 'raises an invalid response error without calling approve' do
      expect { create_subscription }.to raise_error(described_class::InvalidResponseError, /access_token/)
      expect(a_request(:post, approve_url)).not_to have_been_made
    end
  end
end
