RSpec.describe 'OmniAuth providers' do
  subject(:response_status) do
    omniauth_builder.call(Rack::MockRequest.env_for('/auth/proconnect_dirigeant', method: 'POST', 'rack.session' => {})).first
  end

  let(:fallback_app) { ->(_env) { [404, {}, ['Not found']] } }
  let(:builder_block) { Rails.application.middleware.find { |middleware| middleware.klass == OmniAuth::Builder }.block }
  let(:omniauth_builder) { OmniAuth::Builder.new(fallback_app, &builder_block) }

  it 'answers on the dirigeant path' do
    expect(response_status).not_to eq(404)
  end
end
