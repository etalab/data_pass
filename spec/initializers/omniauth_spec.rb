RSpec.describe 'OmniAuth providers' do
  subject(:response_status) do
    omniauth_builder.call(Rack::MockRequest.env_for('/auth/proconnect_dirigeant', method: 'POST', 'rack.session' => {})).first
  end

  let(:fallback_app) { ->(_env) { [404, {}, ['Not found']] } }
  let(:builder_block) { Rails.application.middleware.find { |middleware| middleware.klass == OmniAuth::Builder }.block }
  let(:omniauth_builder) { OmniAuth::Builder.new(fallback_app, &builder_block) }

  before do
    allow(FeatureFlag).to receive(:enabled?).and_call_original
    allow(FeatureFlag).to receive(:enabled?).with(:proconnect_dirigeant).and_return(dirigeant_enabled)
  end

  context 'when the ProConnect dirigeant feature is disabled' do
    let(:dirigeant_enabled) { false }

    it 'does not answer on the dirigeant path' do
      expect(response_status).to eq(404)
    end
  end

  context 'when the ProConnect dirigeant feature is enabled' do
    let(:dirigeant_enabled) { true }

    it 'answers on the dirigeant path' do
      expect(response_status).not_to eq(404)
    end
  end
end
