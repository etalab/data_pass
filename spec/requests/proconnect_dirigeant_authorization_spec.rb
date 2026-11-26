RSpec.describe 'POST /auth/proconnect_dirigeant' do
  subject(:authorization_params) { proconnect_authorization_params(path) }

  let(:path) { '/auth/proconnect_dirigeant?siret_hint=21920023500014' }

  around do |example|
    OmniAuth.config.test_mode = false
    example.run
  ensure
    OmniAuth.config.test_mode = true
  end

  it 'requires the dirigeant certification acr and the amr as claims of the id_token' do
    expect(JSON.parse(authorization_params['claims'])).to eq(
      'id_token' => {
        'acr' => {
          'essential' => true,
          'values' => ['https://proconnect.gouv.fr/assurance/certification-dirigeant']
        },
        'amr' => nil
      }
    )
  end

  it 'sends its own callback as redirect_uri' do
    expect(authorization_params['redirect_uri']).to end_with('/auth/proconnect_dirigeant/callback')
  end

  it 'forwards the SIRET as a hint' do
    expect(authorization_params['siret_hint']).to eq('21920023500014')
  end

  it 'keeps its state and nonce apart from the sign in ones' do
    authorization_params

    expect(session['omniauth.pc_dirigeant.state']).to eq(authorization_params['state'])
    expect(session['omniauth.pc_dirigeant.nonce']).to eq(authorization_params['nonce'])
    expect(session['omniauth.state']).to be_nil
  end

  context 'when the SIRET hint is malformed' do
    let(:path) { '/auth/proconnect_dirigeant?siret_hint=not-a-siret' }

    it 'does not forward it' do
      expect(authorization_params).not_to have_key('siret_hint')
    end
  end
end
