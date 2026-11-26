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

  it 'reports a failed token exchange to Sentry' do
    env['omniauth.error.type'] = :token_exchange_failed

    response

    expect(Sentry).to have_received(:capture_message)
  end

  %i[csrf_detected proconnect_error invalid_credentials].each do |failure_type|
    context "with a #{failure_type} failure, that a visitor or an expected refusal can cause" do
      before do
        env['omniauth.error.type'] = failure_type
        allow(Rails.logger).to receive(:info).and_call_original
      end

      it 'only logs it' do
        response

        expect(Sentry).not_to have_received(:capture_message)
        expect(Rails.logger).to have_received(:info).with(/\[OmniAuth\] authentication failure .*#{failure_type}/)
      end
    end
  end
end
