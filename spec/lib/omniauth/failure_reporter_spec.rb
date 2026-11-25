require Rails.root.join('lib/omniauth/failure_reporter').to_s

RSpec.describe OmniAuth::FailureReporter do
  subject(:response) { described_class.call(env) }

  let(:env) do
    Rack::MockRequest.env_for('/auth/proconnect/callback').merge(
      'omniauth.error.type' => :invalid_id_token,
      'omniauth.error' => StandardError.new('invalid nonce'),
      'omniauth.error.strategy' => instance_double(OmniAuth::Strategies::DataPassProconnect, name: 'proconnect', path_prefix: '/auth')
    )
  end

  before { allow(Sentry).to receive(:capture_message) }

  around do |example|
    original_rack_env = ENV.fetch('RACK_ENV', nil)
    ENV['RACK_ENV'] = 'development'
    example.run
  ensure
    ENV['RACK_ENV'] = original_rack_env
  end

  it 'redirects to the failure endpoint even when RACK_ENV says development' do
    expect(response.first).to eq(302)
    expect(response[1]['Location']).to include('/auth/failure?message=invalid_id_token&strategy=proconnect')
  end

  it 'reports the failure without personal data' do
    response

    expect(Sentry).to have_received(:capture_message).with(
      'OmniAuth authentication failure',
      level: :warning,
      extra: { strategy: 'proconnect', type: :invalid_id_token, error: 'invalid nonce' }
    )
  end
end
